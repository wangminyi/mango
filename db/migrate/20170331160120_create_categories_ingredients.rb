class CreateCategoriesIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :categories_ingredients do |t|
      t.references :category, index: true
      t.references :ingredient, index: true
    end
  end
end
