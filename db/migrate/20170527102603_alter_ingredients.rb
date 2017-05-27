class AlterIngredients < ActiveRecord::Migration[5.0]
  def change
    remove_column :ingredients, :stock
    remove_column :ingredients, :schedule_price

    add_column :ingredients, :sale_mode, :string
    add_column :ingredients, :limit_count, :integer
  end
end
