class ChangeColumnsOfSomeTables < ActiveRecord::Migration[5.0]
  def change
    rename_column :ingredients, :discount, :tags
    rename_column :ingredients, :sale_mode, :unit_text
    remove_column :ingredients, :weight
    add_column :ingredients, :sales_volume, :integer, default: 0
  end
end