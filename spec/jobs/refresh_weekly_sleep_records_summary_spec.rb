require "rails_helper"

RSpec.describe RefreshWeeklySleepRecordsSummaryJob, type: :job do
  it "refreshes the materialized view" do
    expect(ActiveRecord::Base.connection).to receive(:execute).with("REFRESH MATERIALIZED VIEW weekly_sleep_records_summary")
    RefreshWeeklySleepRecordsSummaryJob.perform_now
  end
end
