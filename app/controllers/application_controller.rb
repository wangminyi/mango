class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :require_login
  before_filter :set_user_id

  def require_login
    if !current_user
      sign_in(User.first)
    end
  end

  def set_user_id
    if current_user
      cookies.signed[:user_id] ||= current_user.id
    end
  end
end
