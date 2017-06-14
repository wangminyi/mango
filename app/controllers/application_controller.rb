class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_user_id

  def require_login
    if !current_user
      if Rails.env.development?
        sign_in(User.first)
      else
        store_location_for :user, request.url
        redirect_to "/auth/wechat"
      end
      # sign_in(User.first)
    end
  end

  def set_user_id
    if current_user
      cookies.signed[:user_id] ||= current_user.id
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end
end
