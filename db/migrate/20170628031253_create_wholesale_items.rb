class CreateWholesaleItems < ActiveRecord::Migration[5.0]
  def change
    create_table :wholesale_items do |t|
      t.references :wholesale_entry, index: true

      t.string :name
      t.string :alias
      t.string :image
      t.integer :price
      t.string :unit_text
      t.text :description

      t.integer :sales_volume

      t.timestamps
    end
  end
end
