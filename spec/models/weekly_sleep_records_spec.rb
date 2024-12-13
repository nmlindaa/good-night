require "rails_helper"

RSpec.describe WeeklySleepRecordsSummary, type: :model do
  describe "refresh" do
    it "refreshes the materialized view" do
      expect { WeeklySleepRecordsSummary.refresh }.not_to raise_error
    end
  end
end
