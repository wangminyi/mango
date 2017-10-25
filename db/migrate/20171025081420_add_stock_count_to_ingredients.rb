class AddStockCountToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :stock_count, :integer
  end
end
