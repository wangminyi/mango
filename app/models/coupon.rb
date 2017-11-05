class Coupon < ApplicationRecord
  extend Enumerize

  belongs_to :user

  enumerize :coupon_type, in: [
    :referral,
  ], scope: true

  serialize :extra_info, JSON

  scope :visible, -> { where(used_at: nil).where("coupons.valid_begin_at <= :current AND coupons.valid_end_at >= :current", current: Time.current)}

  def to_json
    {
      id: self.id,
      desc: self.desc,
      amount: self.amount,
      price_limit: self.price_limit,
      coupon_type: self.coupon_type_text,
      valid_from: self.valid_begin_at.strftime("%F"),
      valid_to: self.valid_end_at.strftime("%F"),
    }
  end
end
