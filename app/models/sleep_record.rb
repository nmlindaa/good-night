class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :bed_time, presence: true

  before_save :calculate_duration

  private

  def calculate_duration
    return unless wake_time
    self.duration_minutes = ((wake_time - bed_time) / 60).to_i
  end
end
