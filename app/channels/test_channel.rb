class TestChannel < ApplicationCable::Channel
  def subscribed
    stream_from "test_#{current_user.id}"
  end

  def input data
    ActionCable.server.broadcast "test_#{current_user.id}", data["message"]
  end
end