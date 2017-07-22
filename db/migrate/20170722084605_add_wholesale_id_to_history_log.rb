class AddWholesaleIdToHistoryLog < ActiveRecord::Migration[5.0]
  def change
    add_reference :history_logs, :wholesale_order, index: true
  end
end
