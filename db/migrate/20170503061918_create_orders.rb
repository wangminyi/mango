class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :order_no
      t.string :status

      t.text   :item_details
      t.integer :item_price
      t.integer :distribution_price
      t.string :free_distribution_reason
      t.integer :preferential_price
      t.string :preferential_reason
      t.integer :total_price

      t.string :pay_mode
      t.datetime :distribute_at
      t.references :distributer, index: true

      t.string :reciever_name
      t.string :reciever_address
      t.string :reciever_phone

      t.timestamps
    end

    add_index :orders, :order_no, unique: true
    add_index :orders, :pay_mode
    add_index :orders, :distribute_at
  end
end
