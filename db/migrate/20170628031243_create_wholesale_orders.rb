class CreateWholesaleOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :wholesale_orders do |t|
      t.references :user, index: true
      t.string :order_no
      t.string :pay_status
      t.string :status

      t.references :wholesale_instance, index: true
      t.references :wholesale_item, index: true
      t.integer :item_count
      t.text :item_detail
      t.integer :item_price
      t.integer :preferential_price
      t.integer :total_price

      t.datetime :distribute_at
      t.string :receiver_name
      t.string :receiver_garden
      t.string :receiver_address
      t.string :receiver_phone
      t.string :remark
      t.string :admin_remark

      t.timestamps
    end

    add_index :wholesale_orders, :order_no
    add_index :wholesale_orders, :pay_status
    add_index :wholesale_orders, :status
    add_index :wholesale_orders, :distribute_at
    add_index :wholesale_orders, :receiver_garden
  end
end
