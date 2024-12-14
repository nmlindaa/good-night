require "rails_helper"

RSpec.describe WeeklySleepRecords, type: :model do
  describe "refresh" do
    it "refreshes the materialized view" do
      expect { WeeklySleepRecords.refresh }.not_to raise_error
    end
  end
end
