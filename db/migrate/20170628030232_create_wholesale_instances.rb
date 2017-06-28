class CreateWholesaleInstances < ActiveRecord::Migration[5.0]
  def change
    create_table :wholesale_instances do |t|
      t.references :wholesale_entry, index: true
      t.string :status

      t.string :name
      t.integer :min_count
      t.integer :current_count

      t.datetime :close_at
      t.date :distribute_date_from
      t.date :distribute_date_to

      t.timestamps
    end

    add_index :wholesale_instances, :close_at
  end
end