class AddPayStatusToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :pay_status, :string
    add_index :orders, :pay_status
  end
end
