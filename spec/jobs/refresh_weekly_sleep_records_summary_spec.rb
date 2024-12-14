require "rails_helper"

RSpec.describe RefreshWeeklySleepRecordsJob, type: :job do
  it "refreshes the materialized view" do
    expect(ActiveRecord::Base.connection).to receive(:execute).with("REFRESH MATERIALIZED VIEW weekly_sleep_records")
    RefreshWeeklySleepRecordsJob.perform_now
  end
end
