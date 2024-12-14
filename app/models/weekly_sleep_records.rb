class WeeklySleepRecords < ApplicationRecord
  self.table_name = "weekly_sleep_records"
  belongs_to :user
  belongs_to :follower, class_name: "User"

  def readonly?
    true
  end

  def self.refresh
    connection.execute(
      "REFRESH MATERIALIZED VIEW weekly_sleep_records"
    )
  end
end
