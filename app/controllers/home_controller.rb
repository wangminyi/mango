class HomeController < ApplicationController
  def index
    if current_user.nil?
      sign_in User.first
      redirect_to root_path
    end
  end

  def sign_in
  end
end
