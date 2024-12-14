class RefreshWeeklySleepRecordsJob < ApplicationJob
  queue_as :default

  def perform
    WeeklySleepRecords.refresh
  end
end
