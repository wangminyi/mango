class Admin::OrdersController < Admin::BaseController
  before_action :require_admin
  before_action :set_order, only: [:show, :next_state, :abandon]
  def index
    status = params[:status]
    @orders = Order.all.with_pay_status(:paid).order(created_at: :desc)
    if %w(finished abandon).include? status
      @orders = @orders.with_status(status)
    else
      @orders = @orders.without_status(:finished, :abandon)
    end
  end

  def show
  end

  def next_state
    @order.next_state!
    current_user.history_logs.create(
      action: :handle_order,
      order: @order,
      details: @order.status_text
    )
    render json: {
      finished: @order.status.finished?,
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

  private
    def set_order
      @order = Order.find(params[:id])
    end
end