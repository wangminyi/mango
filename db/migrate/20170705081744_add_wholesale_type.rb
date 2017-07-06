class AddWholesaleType < ActiveRecord::Migration[5.0]
  def change
    add_column :wholesale_entries, :type, :string, after: :alias
    add_column :wholesale_instances, :type, :string, after: :status
    add_column :wholesale_instances, :user_id, :integer, after: :type
    add_column :wholesale_items, :original_price, :integer, after: :price

    add_index :wholesale_instances, :user_id
  end
end
