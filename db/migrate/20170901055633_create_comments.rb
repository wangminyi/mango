class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.references :article, index: true
      t.string :content
      t.string :status

      t.timestamps
    end
  end
end
