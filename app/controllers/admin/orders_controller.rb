class Admin::OrdersController < Admin::BaseController
  before_action :require_admin

  def index
    @orders = Order.all.with_pay_status(:paid).order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
  end
end