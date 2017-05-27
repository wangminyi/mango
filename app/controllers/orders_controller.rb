class OrdersController < ApplicationController
  before_action :set_address, only: [:update, :destroy]

  def create
    order = current_user.orders.build order_param
    order.item_details = JSON.parse(params[:order][:item_details])

    if order.save
      js_pay_req = order.apply_pay
      if js_pay_req.present?
        render json: js_pay_req
      else
        render json: {error: "微信支付失败，请稍后再试"}, status: 501
      end
    else
      head :unprocessable_entity
    end
  end

  def apply_pay
    order = current_user.orders.find(params[:id])
    js_pay_req = order.apply_pay
    if js_pay_req.present?
      render json: {prepay_id: js_pay_req}
    else
      render json: {error: "微信支付失败，请稍后再试"}, status: 501
    end
  end

  def update
    if @address.update(address_param)
      render json: {
        addresses: current_user.addresses_json
      }
    else
      head :unprocessable_entity
    end
  end

  def destroy
    # @address.destroy
    head :ok
  end

  private
    def set_order
      @order = current_user.orders.find(params[:order_id])
    end

    def order_param
      params.require(:order).permit(
        :item_price,
        :pay_mode,
        :distribute_at,
        :receiver_name,
        :receiver_phone,
        :receiver_address,
        :remark,
      )
    end
end
