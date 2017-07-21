class Admin::OrdersController < Admin::BaseController
  before_action :require_admin
  before_action :set_order, only: [:show, :update, :next_state, :abandon, :invoice]

  def index
    @status = params[:status]
    @q  = params[:query] || {}
    # receiver_garden distribute_at_date distribute_at_time

    @orders = Order.all.with_pay_status(:paid).order(:distribute_at)
    if @status.present?
      @orders = @orders.with_status(@status)
      gon.status = @status
    end

    if (receiver_garden = @q[:receiver_garden]).present?
      @orders = @orders.where(receiver_garden: receiver_garden)
    end

    if (distribute_at_date = @q[:distribute_at_date]).present? && (distribute_at_time = @q[:distribute_at_time]).present?
      distribute_at_scope = if distribute_at_time == "morning"
        "#{distribute_at_date} 9:00:00".to_time.."#{distribute_at_date} 11:00:00".to_time
      else
        "#{distribute_at_date} 16:00:00".to_time.."#{distribute_at_date} 19:00:00".to_time
      end
      @orders = @orders.where(distribute_at: distribute_at_scope)
    end

    @active_nav = "#{@status}_order"
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
      action: :handle_order,
      order: @order,
      details: @order.status_text
    )
    render json: {
      html: render_to_string(partial: "order_row", locals: { order: @order })
    }
  end

  def abandon
    @order.abandon!
    current_user.history_logs.create(
      action: :abandon_order,
      order: @order,
    )
    head :ok
  end

  def bulk_push
    orders = Order.where(id: params[:ids])
    if (next_state = orders.first.next_state_value).present?
      orders.update_all(status: next_state)
    end
    head :ok
  end

  def invoice
    @no_footer = true
  end

  def bulk_ingredient
    @no_footer = true
    @orders = Order.where(id: params[:ids].split(","))
  end

  def bulk_export_csv
    @orders = Order.where(id: params[:ids].split(","))
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
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit!
    end
end