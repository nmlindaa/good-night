require "rails_helper"

RSpec.describe SleepRecord, type: :model do
  describe "validations" do
    it "is valid with a bed time" do
      sleep_record = build(:sleep_record, bed_time: Time.now)
      expect(sleep_record).to be_valid
    end

    it "is invalid without a bed time" do
      sleep_record = build(:sleep_record, bed_time: nil)
      expect(sleep_record).to_not be_valid
    end
  end

  describe "callbacks" do
    it "calculates duration correctly" do
      bed_time = Time.now
      wake_time = bed_time + 1.hour
      sleep_record = build(:sleep_record, bed_time: bed_time, wake_time: wake_time)
      sleep_record.save!

      expect(sleep_record.duration_minutes).to eq(60)
    end

    it "does not calculate duration if wake_time is nil" do
      sleep_record = build(:sleep_record, bed_time: Time.now, wake_time: nil)
      sleep_record.save!

      expect(sleep_record.duration_minutes).to be_nil
    end
  end
end
