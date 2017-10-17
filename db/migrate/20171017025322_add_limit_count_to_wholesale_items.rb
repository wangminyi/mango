class AddLimitCountToWholesaleItems < ActiveRecord::Migration[5.0]
  def change
    add_column :wholesale_items, :limit_count, :integer
  end
end
