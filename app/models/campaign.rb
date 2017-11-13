class Campaign < ApplicationRecord
  serialize :configs, JSON

  scope :visible, -> { where("campaigns.start_at <= :current AND campaigns.end_at >= :current", current: Time.current) }

  has_and_belongs_to_many :users

  def to_json
    self.configs.merge(
      "id" => self.id,
      "code" => self.code
    )
  end

  def is_active?
    (self.start_at..self.end_at).cover? Time.current
  end

  def is_used? user
    !user.role.admin? && self.users.exists?(user.id)
  end
end
