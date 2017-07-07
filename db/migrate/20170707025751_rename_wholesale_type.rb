class RenameWholesaleType < ActiveRecord::Migration[5.0]
  def change
    rename_column :wholesale_entries, :type, :mode
    rename_column :wholesale_instances, :type, :mode
  end
end
