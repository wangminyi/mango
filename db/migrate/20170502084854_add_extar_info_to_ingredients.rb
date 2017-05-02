class AddExtarInfoToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :order_limit, :integer
    add_column :ingredients, :schedule_price, :integer
  end
end
