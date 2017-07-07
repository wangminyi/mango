class ChangeWholesaleOrdersItemDetailName < ActiveRecord::Migration[5.0]
  def change
    rename_column :wholesale_orders, :item_detail, :item_details
  end
end
