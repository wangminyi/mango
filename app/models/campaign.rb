class Campaign < ApplicationRecord
  serialize :configs, JSON

  scope :visible, -> { where("campaigns.start_at <= :current AND campaigns.end_at >= :current", current: Time.current) }
end
