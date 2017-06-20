class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from "Exception", with: :notify_exception

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

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def notify_exception e
    SlackNotifier.notify e.to_s
    raise e
  end
end
