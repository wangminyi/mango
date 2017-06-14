class Admin::OrdersController < Admin::BaseController
  # before_action :sign_in_by_params, only: [:index]
  before_action :require_admin

  def index
    @orders = Order.all.with_pay_status(:paid).order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
  end

  private
    def require_admin
      if current_user.blank?
        store_location_for(:user, request.url)
        redirect_to new_user_session_path
      elsif !current_user.role.admin?
        raise ActionController::RoutingError.new('Not Found')
      end
    end
end