class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :validatable

  stores_emoji_characters :nickname

  extend Enumerize

  enumerize :role, in: [
    :user,
    :admin
  ], scope: true, default: :user

  has_many :orders
  has_many :wholesale_orders
  has_many :addresses
  has_many :history_logs

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def addresses_json
    self.addresses.order(updated_at: :desc).map(&:as_json)
  end
end
