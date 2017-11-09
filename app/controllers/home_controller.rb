class HomeController < ApplicationController
  def index

  end

  def trigger_error
    raise Exception.new("test error")
  end

  def speak_to_robot
    message = params[:message]
    result = JSON.parse(RestClient.get "http://www.tuling123.com/openapi/api", {:params => { :key => '6c78bae3a1fc2e4b2b7ca3b70dd195c1', :info => message}})
    render json: {
      message: result["text"]
    }
  end
end
