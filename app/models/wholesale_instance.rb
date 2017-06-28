class WholesaleInstance < ApplicationRecord
  extend Enumerize

  enumerize :status, in: [
    :visible,
    :invisible,
  ], scope: true, default: :visible

  belongs_to :wholesale_instance

  def as_json
    {
      id: self.id,
      name: self.name,
      min_count: self.min_count,
      current_count: self.current_count,
      distribute_date_from: distribute_date_from,
      distribute_date_to: distribute_date_to,
    }
  end
end
