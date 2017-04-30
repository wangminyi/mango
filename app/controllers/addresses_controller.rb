class AddressesController < ApplicationController
  before_action :set_address, only: [:update, :destroy]

  def create
    address = current_user.addresses.build(address_param)
    if address.save
      render json: {
        addresses: current_user.addresses_json
      }
    else
      head :unprocessable_entity
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
    def set_address
      @address = current_user.addresses.find(params[:address_id])
    end

    def address_param
      params.require(:address).permit(
        :name,
        :gender,
        :phone,
        :garden,
        :house_number,
        :is_default,
      )
    end
end
