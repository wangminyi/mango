class OrdersController < ApplicationController
  before_action :set_address, only: [:update, :destroy]

  def create
    order = current_user.orders.build order_param
    order.item_details = params[:order][:item_details]
    binding.pry
    head :ok
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
