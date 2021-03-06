class CreateWholesaleEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :wholesale_entries do |t|
      t.string :name
      t.string :status

      t.string :cover_image
      t.text :detail_images

      t.text :summary
      t.text :detail
      t.text :tips

      t.integer :min_count

      t.timestamps
    end

    add_index :wholesale_entries, :name
    add_index :wholesale_entries, :status
  end
end
