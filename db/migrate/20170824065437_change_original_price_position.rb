class ChangeOriginalPricePosition < ActiveRecord::Migration[5.0]
  def change
    change_column :ingredients, :original_price, :integer, after: :price
  end
end
