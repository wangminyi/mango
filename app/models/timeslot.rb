class Timeslot < ApplicationRecord
  belongs_to :user

  enumerize :slot_type, in: [
    :play,
    :study,
    :rest,
    :others,
  ], default: :others

  enumerize :slot_state, in: [
    :recording,
    :ended,
  ]

  before_create :init_record

  def stop
    self.update(
      slot_state: :ended,
      ended_at: Time.current
    )
  end

  def init_record
    self.assign_attributes(
      slot_state: :recording,
      started_at: Time.current
    )
  end

  def as_json
    {
      id: self.id,
      slot_type: self.slot_type_text,
      slot_state: self.slot_state_text,
      started_at: self.started_at.strftime("%Y/%m/%d %T"),
      ended_at: (self.ended_at.strftime("%Y/%m/%d %T") if self.ended_at),
      current_time: Time.current.strftime("%Y/%m/%d %T"),
    }
  end
end
