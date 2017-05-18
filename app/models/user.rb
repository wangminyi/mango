class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :orders
  has_many :addresses

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
