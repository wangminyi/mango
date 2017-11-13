class OrdersController < ApplicationController
  before_action :require_login, only: [:index, :show]

  def index
    orders = current_user.orders
    wholesale_orders = current_user.wholesale_orders
    @orders = (orders + wholesale_orders).sort_by(&:created_at).reverse
  end

  def show
    if params[:from] == "shop"
      gon.js_config_params = Wx.js_config_params(request.url)
    end
    @order = current_user.orders.find params[:id]
  end

  def create
    is_first = current_user.role.admin? || current_user.orders.with_pay_status(:paid).empty?
    order = current_user.orders.build order_param

    gifts = is_first ? JSON.parse(params[:order][:gifts]) : []
    referee_id = if is_first && (code = params[:referral_code]).present? && (referee = User.find_by(referral_code: code)).present?
      referee.id
    end

    order.assign_attributes(
      item_list: JSON.parse(params[:order][:item_list]),
      gifts: gifts,
      referee_id: referee_id
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
      render json: {
        error: order.errors.full_messages[0]
      }, status: :unprocessable_entity
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
        :coupon_id,
        :campaign_id,
        :receiver_name,
        :receiver_garden,
        :receiver_phone,
        :receiver_address,
        :remark,
      )
    end
end
