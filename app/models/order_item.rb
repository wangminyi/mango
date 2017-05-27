class OrderItem < ApplicationRecord
  extend Enumerize

  enumerize :type, in: [
    :ingredient,
    :gift,
  ], scope: true
end
