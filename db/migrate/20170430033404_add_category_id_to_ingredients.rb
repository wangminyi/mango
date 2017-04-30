class AddCategoryIdToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :category_id, :integer
    add_index :ingredients, :category_id

    drop_table :categories_ingredients
  end
end
