FactoryBot.define do
  factory :sleep_record do
    association :user
    bed_time { Time.current }
    wake_time { nil }
    duration_minutes { nil }

    trait :closed do
      wake_time { bed_time + 8.hours }
      duration_minutes { (wake_time - bed_time) / 60 }
    end
  end
end
