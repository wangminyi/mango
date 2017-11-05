class CreateCoupons < ActiveRecord::Migration[5.0]
  def change
    create_table :coupons do |t|
      t.references :user, index: true
      t.string :desc # 描述文字
      t.integer :amount # 金额
      t.integer :price_limit # 最低消费
      t.string :coupon_type # 类型
      t.datetime :used_at
      t.datetime :valid_begin_at # 有效期
      t.datetime :valid_end_at
      t.text :extra_info
      t.timestamps

      t.index :used_at
      t.index :valid_begin_at
      t.index :valid_end_at
    end

  end
end
