class AddAliasToWholesaleEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :wholesale_entries, :alias, :string, after: :name
  end
end
