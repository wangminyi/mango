class CreateHistoryLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :history_logs do |t|
      t.string :action
      t.references :user, index: true
      t.references :order, index: true
      t.text :details

      t.timestamps
    end

    add_index :history_logs, :action
  end
end
