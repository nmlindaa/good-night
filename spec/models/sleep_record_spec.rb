require "rails_helper"

RSpec.describe SleepRecord, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:bed_time) }

    it "validates that wake_time is after bed_time" do
      sleep_record = build(:sleep_record, bed_time: Time.current, wake_time: 1.hour.ago)
      expect(sleep_record).not_to be_valid
      expect(sleep_record.errors[:wake_time]).to include("must be after bed time")
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe ".clock_in" do
    it "creates a new sleep record" do
      expect {
        SleepRecord.clock_in(user)
      }.to change(SleepRecord, :count).by(1)
    end

    it "sets the bed_time to the current time" do
      Timecop.freeze do
        sleep_record = SleepRecord.clock_in(user)
        expect(sleep_record.bed_time).to be_within(1.second).of(Time.current)
      end
    end

    it "returns false if there is an existing open sleep record" do
      create(:sleep_record, user: user, wake_time: nil)
      expect(SleepRecord.clock_in(user)).to be false
    end
  end

  describe ".clock_out" do
    it "updates the wake_time of the open sleep record" do
      sleep_record = create(:sleep_record, user: user, wake_time: nil)
      Timecop.freeze do
        SleepRecord.clock_out(user)
        sleep_record.reload
        expect(sleep_record.wake_time).to be_within(1.second).of(Time.current)
      end
    end

    it "returns false if there is no open sleep record" do
      expect(SleepRecord.clock_out(user)).to be false
    end

    it "calculates the duration_minutes" do
      sleep_record = create(:sleep_record, user: user, bed_time: 2.hours.ago, wake_time: nil)
      SleepRecord.clock_out(user)
      sleep_record.reload
      expect(sleep_record.duration_minutes).to be_within(1).of(120)
    end
  end

  describe "preventing overlapping records" do
    it "does not allow creating a new record when an open one exists" do
      create(:sleep_record, user: user, wake_time: nil)
      new_record = build(:sleep_record, user: user)
      expect(new_record).not_to be_valid
      expect(new_record.errors[:base]).to include("An open sleep record already exists")
    end
  end

  describe "updates after wake_time is set" do
    let(:sleep_record) { create(:sleep_record, user: user, bed_time: 2.hours.ago, wake_time: 1.hour.ago) }

    it "prevents updating bed_time after wake_time is set" do
      sleep_record.bed_time = 3.hours.ago
      expect(sleep_record.save).to be false
      expect(sleep_record.errors[:base]).to include("Cannot update bed_time or user after wake_time is set")
    end

    it "prevents updating user after wake_time is set" do
      new_user = create(:user)
      sleep_record.user = new_user
      expect(sleep_record.save).to be false
      expect(sleep_record.errors[:base]).to include("Cannot update bed_time or user after wake_time is set")
    end
    it "allows updating wake_time after it has been set" do
      sleep_record.wake_time = 30.minutes.ago
      expect(sleep_record.save).to be true
      expect(sleep_record.duration_minutes).to be_within(1).of(90)
    end
  end

  describe "callbacks" do
    describe "calculate_duration" do
      it "calculates duration_minutes when wake_time is set" do
        sleep_record = create(:sleep_record, bed_time: 2.hours.ago, wake_time: nil)
        sleep_record.update(wake_time: Time.current)
        expect(sleep_record.duration_minutes).to be_within(1).of(120)
      end

      it "recalculates duration_minutes when wake_time is updated" do
        sleep_record = create(:sleep_record, bed_time: 3.hours.ago, wake_time: 1.hour.ago)
        sleep_record.update(wake_time: Time.current)
        expect(sleep_record.duration_minutes).to be_within(1).of(180)
      end
    end
  end

  describe "scopes" do
    let(:user_2) { create(:user) }
    let!(:open_record) { create(:sleep_record, user: user_2, bed_time: 1.hour.ago) }

    let!(:closed_record) do
      Timecop.freeze(2.hours.from_now) do
        create(:sleep_record, user: user, bed_time: 1.hour.ago, wake_time: Time.current)
      end
    end

    describe ".open" do
      it "returns only open sleep records" do
        expect(SleepRecord.open).to include(open_record)
        expect(SleepRecord.open).not_to include(closed_record)
      end
    end

    describe ".closed" do
      it "returns only closed sleep records" do
        expect(SleepRecord.closed).to include(closed_record)
        expect(SleepRecord.closed).not_to include(open_record)
      end
    end
  end

  describe "instance methods" do
    describe "#open?" do
      it "returns true for open sleep records" do
        sleep_record = create(:sleep_record, bed_time: 1.hour.ago)
        expect(sleep_record.open?).to be true
      end

      it "returns false for closed sleep records" do
        Timecop.freeze(Time.current) do
          sleep_record = create(:sleep_record, bed_time: 2.hours.ago, wake_time: 1.hour.ago)
          expect(sleep_record.open?).to be false
        end
      end
    end

    describe "#closed?" do
      it "returns false for open sleep records" do
        sleep_record = create(:sleep_record, bed_time: 1.hour.ago)
        expect(sleep_record.closed?).to be false
      end

      it "returns true for closed sleep records" do
        Timecop.freeze(Time.current) do
          sleep_record = create(:sleep_record, bed_time: 2.hours.ago, wake_time: 1.hour.ago)
          expect(sleep_record.closed?).to be true
        end
      end
    end
  end

  describe "edge cases" do
    it "handles bed_time and wake_time in different time zones" do
      sleep_record = create(:sleep_record,
                            bed_time: Time.current.in_time_zone("Eastern Time (US & Canada)"),
                            wake_time: 8.hours.from_now.in_time_zone("Pacific Time (US & Canada)"))
      expect(sleep_record).to be_valid
      expect(sleep_record.duration_minutes).to be_within(1).of(480)
    end

    it "handles sleep records spanning multiple days" do
      bed_time = 2.days.ago.beginning_of_day
      wake_time = Time.current.end_of_day
      sleep_record = create(:sleep_record, bed_time: bed_time, wake_time: wake_time)

      expect(sleep_record).to be_valid

      expected_duration = ((wake_time - bed_time) / 60).round
      expect(sleep_record.duration_minutes).to be_within(1).of(expected_duration)
    end
  end
end
