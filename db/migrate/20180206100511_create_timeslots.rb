class CreateTimeslots < ActiveRecord::Migration[5.0]
  def change
    create_table :timeslots do |t|
      t.references :user, index: true

      t.string :slot_type
      t.string :slot_state

      t.string :description
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
