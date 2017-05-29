class Admin::OrdersController < Admin::BaseController
  before_action :sign_in_by_params, only: [:index]
  before_action :require_admin

  def index
    @orders = Order.all.order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
  end

  private
    def require_admin
      unless current_user&.role&.admin?
        raise ActionController::RoutingError.new('Not Found')
      end
    end
end