class ChangeWholesaleItemsSalesVolume < ActiveRecord::Migration[5.0]
  def change
    change_column :wholesale_items, :sales_volume, :integer, default: 0
  end
end
