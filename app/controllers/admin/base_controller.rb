class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :require_admin

  def require_admin
    if current_user.blank?
      store_location_for(:user, request.url)
      redirect_to new_user_session_path
    elsif !current_user.role.admin?
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end