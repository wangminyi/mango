class WholesaleOrdersController < ApplicationController
  before_action :require_login, only: [:index, :show]

  def index
    @orders = current_user.wholesale_orders.order(created_at: :desc)
  end

  def show
    if params[:from] == "shop"
      gon.js_config_params = Wx.js_config_params(request.url)
    end
    @order = current_user.wholesale_orders.find params[:id]
  end

  def create
    order = current_user.wholesale_orders.build order_param
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
        :wholesale_instance_id,
        :wholesale_item_id,
        :item_count,
        :item_price,
        :total_price,
        :preferential_price,
        :receiver_name,
        :receiver_garden,
        :receiver_phone,
        :receiver_address,
        :remark,
      )
    end
end
