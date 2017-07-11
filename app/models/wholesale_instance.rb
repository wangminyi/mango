class WholesaleInstance < ApplicationRecord
  extend Enumerize

  enumerize :mode, in: [
    :platform,
    :user,
  ], scope: true

  enumerize :status, in: [
    :visible,
    :invisible,
  ], scope: true, default: :visible

  enumerize :distribute_scope, in: [
    :morning,
    :afternoon,
    :all_day,
  ], scope: true, default: :all_day

  belongs_to :wholesale_entry
  belongs_to :user
  has_many :wholesale_orders

  def as_json
    {
      id: self.id,
      name: self.name,
      short_name: self.name.split(/[(（]/)[0],
      mode: self.mode,
      min_count: self.min_count,
      current_count: self.current_count,
      distribute_scope: self.distribute_scope,
      distribute_date_from: distribute_date_from,
      distribute_date_to: distribute_date_to,
    }
  end

  def participants
  end
end
