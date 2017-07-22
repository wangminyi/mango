class HistoryLog < ApplicationRecord
  extend Enumerize

  enumerize :action, in: [
    :sign_in,
    :handle_order,
    :abandon_order,
    :handle_wholesale_order,
    :abandon_wholesale_order,
  ], scope: true

  belongs_to :order
  belongs_to :wholesale_order
  belongs_to :user
end
