class AddSecondaryTagToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :secondary_tag, :string
  end
end
