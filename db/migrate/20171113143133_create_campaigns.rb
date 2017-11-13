class CreateCampaigns < ActiveRecord::Migration[5.0]
  def change
    create_table :campaigns do |t|
      t.string :code
      t.string :desc
      t.text :configs
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
