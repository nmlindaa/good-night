class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :bed_time, presence: true
  validate :wake_time_after_bed_time
  validate :no_overlapping_records, on: :create

  before_save :calculate_duration, if: :wake_time_changed?
  before_update :prevent_updates_after_wake_time_set

  def self.clock_in(user)
    return false if user.sleep_records.where(wake_time: nil).exists?

    create(user: user, bed_time: Time.current)
  end

  def self.clock_out(user)
    record = user.sleep_records.find_by(wake_time: nil)
    return false unless record

    record.update(wake_time: Time.current)
  end

  private

  def wake_time_after_bed_time
    return unless wake_time && bed_time

    if wake_time <= bed_time
      errors.add(:wake_time, "must be after bed time")
    end
  end

  def no_overlapping_records
    if user && user.sleep_records.where(wake_time: nil).exists?
      errors.add(:base, "An open sleep record already exists")
    end
  end

  def calculate_duration
    return unless wake_time && bed_time

    self.duration_minutes = ((wake_time - bed_time) / 60).round
  end

  def prevent_updates_after_wake_time_set
    if wake_time_was.present? && (bed_time_changed? || user_id_changed?)
      errors.add(:base, "Cannot update bed_time or user after wake_time is set")
      throw :abort
    end
  end
end
