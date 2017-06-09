class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_user_id

  def require_login
    if !current_user
      if Rails.env.development?
        sign_in(User.first)
      else
        store_location_for :user, request.url
        redirect_to "/auth/wechat/callback"
      end
      # sign_in(User.first)
    end
  end

  def set_user_id
    if current_user
      cookies.signed[:user_id] ||= current_user.id
    end
  end
end
