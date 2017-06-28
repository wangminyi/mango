class WholesaleEntry < ApplicationRecord
  extend Enumerize

  enumerize :status, in: [
    :visible,
    :invisible,
    :deprecated,
  ]

  has_many :wholesale_instances
end
