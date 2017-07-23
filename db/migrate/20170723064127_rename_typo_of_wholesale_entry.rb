class RenameTypoOfWholesaleEntry < ActiveRecord::Migration[5.0]
  def change
    rename_column :wholesale_entries, :vislble, :visible
  end
end
