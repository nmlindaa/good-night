class WeeklySleepRecordsSummary < ApplicationRecord
  self.table_name = "weekly_sleep_records_summary"
  belongs_to :user
  belongs_to :follower, class_name: "User"

  def readonly?
    true
  end

  def self.refresh
    connection.execute(
      "REFRESH MATERIALIZED VIEW weekly_sleep_records_summary"
    )
  end
end
