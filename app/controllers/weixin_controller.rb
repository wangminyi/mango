class WeixinController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :auto_signin
  def test_weixin
    render json: {
      hello: :world
    }
  end

  def current_status
    render json: {
      is_recording: current_user.is_recording?,
      current_slot: current_user.recording_timeslots.first&.as_json,
    }
  end

  def start_recording
    timeslot = current_user.recording_timeslots.build(slot_type: params[:slot_type])
    if timeslot.save
      render json: {
        current_slot: timeslot.as_json
      }
    else
      head :unprocessable_entity
    end
  end

  def stop_recording
    timeslot = current_user.recording_timeslots.find(params[:id])
    if timeslot.stop
      render json: {
        data: timeslot.as_json
      }
    else
      head :unprocessable_entity
    end
  end

  private
    def auto_signin
      unless current_user.present?
        sign_in(User.first)
      end
    end
end
