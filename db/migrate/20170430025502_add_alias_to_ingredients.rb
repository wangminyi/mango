class AddAliasToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :alias, :string, after: :name
    add_index :ingredients, :alias
  end
end
