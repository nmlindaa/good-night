class CreateWeeklySleepSummaryView < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW weekly_sleep_records_summary AS
      SELECT
        sr.id,
        sr.user_id,
        f.follower_id,
        sr.bed_time,
        sr.wake_time,
        sr.duration_minutes
      FROM sleep_records sr
      INNER JOIN follows f ON sr.user_id = f.followed_id
      WHERE sr.bed_time >= NOW() - INTERVAL '7 days' AND sr.wake_time IS NOT NULL
      ORDER BY sr.duration_minutes DESC;
    SQL

    add_index :weekly_sleep_records_summary, [ :follower_id, :user_id ], name: 'index_weekly_sleep_records_summary'
  end

  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS weekly_sleep_records_summary;
    SQL
  end
end
