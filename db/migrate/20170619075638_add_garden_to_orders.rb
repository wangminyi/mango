class AddGardenToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :receiver_garden, :string, after: :receiver_name
    add_index :orders, :receiver_garden
  end
end
