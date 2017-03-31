class CreateIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :ingredients do |t|
      t.string :name
      t.string :image
      t.integer :price
      t.integer :weight
      t.text :description
      t.integer :stock

      t.timestamps
    end

    add_index :ingredients, :name
    add_index :ingredients, :stock
  end
end