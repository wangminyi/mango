class HomeController < ApplicationController
  def index

  end

  def trigger_error
    raise Exception.new("test error")
  end
end
