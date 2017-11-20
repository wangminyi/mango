class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:speak_to_robot]

  def index

  end

  def trigger_error
    raise Exception.new("test error")
  end

  def speak_to_robot
    message = params[:message]
    result = JSON.parse(RestClient.post "http://47.94.75.98/openapi/api", {
      :key => '6c78bae3a1fc2e4b2b7ca3b70dd195c1',
      :info => message,
      :userid => "19871228"
    })

    render json: {
      message: result["text"]
    }
  end
end
