class AddOriginalPriceToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :original_price, :integer
  end
end
