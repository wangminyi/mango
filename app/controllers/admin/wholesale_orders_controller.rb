class Admin::WholesaleOrdersController < Admin::BaseController
  before_action :set_order, only: [:show, :update, :next_state, :abandon, :invoice]

  def index
    # 状态 meet unmeet all
    @status = params[:status] || "submitted"

    @orders = WholesaleOrder.all.with_pay_status(:paid).with_status(@status).order(:distribute_at)

    # if (receiver_garden = @q[:receiver_garden]).present?
    #   @orders = @orders.where(receiver_garden: receiver_garden)
    # end

    # if (distribute_at_date = @q[:distribute_at_date]).present? && (distribute_at_time = @q[:distribute_at_time]).present?
    #   distribute_at_scope = if distribute_at_time == "morning"
    #     "#{distribute_at_date} 9:00:00".to_time.."#{distribute_at_date} 11:00:00".to_time
    #   else
    #     "#{distribute_at_date} 16:00:00".to_time.."#{distribute_at_date} 19:00:00".to_time
    #   end
    #   @orders = @orders.where(distribute_at: distribute_at_scope)
    # end

    @active_nav = "#{@status}_wholesale_order"
  end

  def show
  end

  def update
    @order.update(order_params)
    head :ok
  end

  def next_state
    @order.next_state!
    current_user.history_logs.create(
      action: :handle_wholesale_order,
      wholesale_order: @order,
      details: @order.status_text
    )
    render json: {
      html: render_to_string(partial: "order_row", locals: { order: @order })
    }
  end

  def abandon
    @order.abandon!
    current_user.history_logs.create(
      action: :abandon_wholesale_order,
      wholesale_order: @order,
    )
    head :ok
  end

  def invoice
    @no_footer = true
  end

  def bulk_export_csv
    @orders = WholesaleOrder.where(id: params[:ids].split(","))
    field_names = %w(
      订单号
      地址
      配送时间
      商品名称
      份数
      单价
      总价
    )
    data = CSV.generate do |csv|
      csv << field_names
      @orders.each do |order|
        first_row = true
        order.item_details.each do |ingredent|
          row = if first_row
              first_row = false
              [
                order.id,
                order.receiver_address,
                order.distribute_at.strftime("%F %T"),
              ]
            else
              [
                nil,
                nil,
                nil,
              ]
            end + [
              ingredent["name"],
              ingredent["count"],
              "%.2f" % (ingredent["price"].to_i / 100.0),
              "%.2f" % (ingredent["price"].to_i * ingredent["count"].to_i / 100.0),
            ]
          csv << row
        end
      end
    end
    send_data data, filename: "订单.csv"
  end

  private
    def set_order
      @order = WholesaleOrder.find(params[:id])
    end

    def order_params
      params.require(:wholesale_order).permit!
    end
end