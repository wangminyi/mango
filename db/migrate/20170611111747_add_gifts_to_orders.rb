class AddGiftsToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :gifts, :text
    add_column :orders, :item_list, :text
  end
end
