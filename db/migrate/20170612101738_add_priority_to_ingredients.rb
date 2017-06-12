class AddPriorityToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :priority, :integer, default: 0
    add_index :ingredients, :priority
  end
end
