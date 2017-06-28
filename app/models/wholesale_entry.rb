class WholesaleEntry < ApplicationRecord
  extend Enumerize

  enumerize :status, in: [
    :visible,
    :invisible,
    :deprecated,
  ], scope: true, default: :visible

  has_many :wholesale_instances

  def instance_template
    {
      min_count: self.min_count,
    }
  end
end
