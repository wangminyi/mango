class AddIsHotToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :is_hot, :boolean, default: false
  end
end
