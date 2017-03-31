class CreateDishesIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :dishes_ingredients do |t|
      t.references :dish, index: true
      t.references :ingredient, index: true
      t.integer :weight
    end
  end
end
