class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records, id: :uuid do |t|
      t.uuid :user_id
      t.datetime :bed_time, null: false
      t.datetime :wake_time
      t.integer :duration_minutes
      t.timestamps
    end
    add_foreign_key :sleep_records, :users, column: :user_id
    add_index :sleep_records, [ :bed_time, :duration_minutes ]
  end
end
