class ChangeWholesaleInstanceColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :wholesale_instances, :visible, :boolean, default: true

    remove_column :wholesale_entries, :status
    add_column :wholesale_entries, :vislble, :boolean, default: true
  end
end
