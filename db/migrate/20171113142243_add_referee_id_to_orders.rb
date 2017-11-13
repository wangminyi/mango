class AddRefereeIdToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :referee_id, :integer
  end
end
