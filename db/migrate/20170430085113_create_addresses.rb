class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.references :user, index: true
      t.string :name
      t.string :gender
      t.string :phone
      t.string :garden
      t.string :house_number
      t.boolean :is_default

      t.timestamps
    end
  end
end
