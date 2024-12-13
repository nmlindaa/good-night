FactoryBot.define do
  factory :sleep_record do
    association :user, factory: :user
    bed_time { Time.now - 8.hour }
    wake_time { Time.now }
  end
end
