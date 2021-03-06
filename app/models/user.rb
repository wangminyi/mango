class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :validatable

  stores_emoji_characters :nickname

  extend Enumerize

  enumerize :role, in: [
    :user,
    :admin,
    :super_admin,
  ], scope: true, default: :user

  has_many :orders
  has_many :wholesale_orders
  has_many :addresses
  has_many :history_logs
  has_many :articles
  has_many :timeslots

  def recording_timeslots
    self.timeslots.where(slot_state: :recording)
  end

  def is_recording?
    self.recording_timeslots.present?
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def addresses_json
    self.addresses.order(updated_at: :desc).map(&:as_json)
  end

  def is_super_admin?
    !Rails.env.production? || self.id == 2
  end
end
