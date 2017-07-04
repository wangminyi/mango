class WholesaleInstance < ApplicationRecord
  extend Enumerize

  enumerize :status, in: [
    :visible,
    :invisible,
  ], scope: true, default: :visible

  belongs_to :wholesale_entry

  delegate :type, to: :wholesale_entry

  def as_json
    {
      id: self.id,
      name: self.name,
      short_name: self.name.split(/[(（]/)[0],
      min_count: self.min_count,
      current_count: self.current_count,
      distribute_date_from: distribute_date_from,
      distribute_date_to: distribute_date_to,
    }
  end
end
