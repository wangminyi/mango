class HistoryLog < ApplicationRecord
  extend Enumerize

  enumerize :action, in: [
    :handle_order,
    :abandon_order,
  ], scope: true

  belongs_to :order
  belongs_to :user
end
