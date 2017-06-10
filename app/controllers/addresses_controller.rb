class AddressesController < ApplicationController
  before_action :set_address, only: [:update, :destroy]

  def create
    address = current_user.addresses.build(address_param)
    if address.save
      render json: {
        addresses: current_user.addresses_json
      }
    else
      render json: {
        error: address.first_error
      }, status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_param)
      render json: {
        addresses: current_user.addresses_json
      }
    else
      render json: {
        error: @address.first_error
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    head :ok
  end

  private
    def set_address
      @address = current_user.addresses.find(params[:address_id])
    end

    def address_param
      params[:address][:is_default] = (params[:address][:is_default] == "true" ? 1 : 0)

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
