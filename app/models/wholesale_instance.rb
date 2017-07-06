class WholesaleInstance < ApplicationRecord
  extend Enumerize

  enumerize :type, in: [
    :platform,
    :user,
  ], scope: true

  enumerize :status, in: [
    :visible,
    :invisible,
  ], scope: true, default: :visible

  belongs_to :wholesale_entry
  belongs_to :user
  has_many :wholesale_orders

  def as_json
    {
      id: self.id,
      name: self.name,
      short_name: self.name.split(/[(（]/)[0],
      type: self.type,
      min_count: self.min_count,
      current_count: self.current_count,
      distribute_date_from: distribute_date_from,
      distribute_date_to: distribute_date_to,
    }
  end

  def participants
  end
end
