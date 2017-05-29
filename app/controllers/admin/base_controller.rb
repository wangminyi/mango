class Admin::BaseController < ApplicationController
  def sign_in_by_params
    id = params[:id]
    password = params[:password]
    user = User.with_role(:admin).find(id)

    if user.valid_password? password
      sign_in user
    end
  end
end