class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :order_no
      t.references :user, index: true
      t.string :pay_status
      t.string :status

      t.text   :item_details
      t.integer :item_price
      t.integer :distribution_price # 配送费
      t.string :free_distribution_reason # 免配送原因
      t.integer :preferential_price # 优惠
      t.string :preferential_reason # 优惠原因
      t.integer :total_price

      t.datetime :distribute_at
      t.references :distributer, index: true

      t.string :receiver_name
      t.string :receiver_address
      t.string :receiver_phone

      t.text :remark

      t.timestamps
    end

    add_index :orders, :order_no, unique: true
    add_index :orders, :distribute_at
  end
end
