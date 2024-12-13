FactoryBot.define do
  factory :sleep_record do
    association :user
    bed_time { Time.current }
    wake_time { nil }
    duration_minutes { nil }
  end
end
