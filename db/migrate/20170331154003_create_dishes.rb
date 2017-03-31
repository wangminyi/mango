class CreateDishes < ActiveRecord::Migration[5.0]
  def change
    create_table :dishes do |t|
      t.string :name
      t.string :image
      t.text :description

      t.timestamps
    end

    add_index :dishes, :name
  end
end
