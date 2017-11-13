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
  has_many :coupons
  has_many :referrers, class_name: "User", foreign_key: "referee_id"
  belongs_to :referee, class_name: "User"

  before_create :set_referral_code

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

  def set_referral_code
    self.referral_code = loop do
      temp = SecureRandom.rand 1000..9999
      break temp if !User.exists?(referral_code: temp)
    end
  end

  def generate_referral_code
    self.set_referral_code
    self.save
  end

  def no_paid_order?
    self.role.admin? || self.orders.with_pay_status(:paid).empty?
  end
end
