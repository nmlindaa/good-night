class RefreshWeeklySleepRecordsSummaryJob < ApplicationJob
  queue_as :default

  def perform
    WeeklySleepRecordsSummary.refresh
  end
end
