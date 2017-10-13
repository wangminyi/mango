class CreateGardens < ActiveRecord::Migration[5.0]
  def change
    create_table :gardens do |t|
      t.string :name
      t.string :address
      t.integer :distribution_price
      t.integer :free_price
      t.boolean :visible, default: true
      t.index :visible

      t.timestamps
    end
  end
end
