class CreateOrderItems < ActiveRecord::Migration[5.0]
  def change
    create_table :order_items do |t|
      t.references :order, index: true

      t.string :name
      t.string :img
      t.integer :count
      t.integer :price
      t.string :type
      t.integer :relation_id

      t.timestamps
    end
  end
end
