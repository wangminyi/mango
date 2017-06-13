class OrdersController < ApplicationController
  before_action :require_login, only: [:index, :show]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find params[:id]
  end

  def create
    order = current_user.orders.build order_param
    order.assign_attributes(
      item_list: JSON.parse(params[:order][:item_list]),
      gifts: JSON.parse(params[:order][:gifts])
    )
    if order.save
      js_pay_req = order.apply_prepay
      if js_pay_req.present?
        render json: {
          pay_params: js_pay_req,
          order_url: order_url(order),
        }
      else
        render json: {error: "微信支付失败，请稍后再试"}, status: 501
      end
    else
      head :unprocessable_entity
    end
  end

  def apply_pay
    order = current_user.orders.find(params[:id])
    js_pay_req = order.apply_prepay
    if js_pay_req.present?
      render json: {js_pay_params: js_pay_req}
    else
      render json: {error: "微信支付失败，请稍后再试"}, status: 501
    end
  end

  private
    def set_order
      @order = current_user.orders.find(params[:order_id])
    end

    def order_param
      params.require(:order).permit(
        :item_price,
        :total_price,
        :distribute_at,
        :distribution_price,
        :free_distribution_reason,
        :preferential_price,
        :receiver_name,
        :receiver_phone,
        :receiver_address,
        :remark,
      )
    end
end
