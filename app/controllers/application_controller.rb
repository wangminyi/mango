class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :set_user_id

  def set_user_id
    if current_user
      cookies.signed[:user_id] ||= current_user.id
    end
  end
end
