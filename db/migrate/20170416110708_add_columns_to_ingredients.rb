class AddColumnsToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :dishes, :cooking_method, :text

    add_column :ingredients, :discount, :string
    add_column :ingredients, :texture, :string

    add_index :ingredients, :discount
  end
end
