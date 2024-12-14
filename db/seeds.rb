puts "Clearing existing data..."
User.destroy_all
SleepRecord.destroy_all
Follow.destroy_all

puts "Creating users..."
users = []
50.times do
  users << User.create!(
    name: Faker::Name.name,
  )
end

puts "Creating sleep records..."
users.each do |user|
  5.times do
    bedtime = Faker::Time.between(from: 30.days.ago, to: 1.days.ago)

    sleep_record = SleepRecord.create!(
      user: user,
      bed_time: bedtime
    )

    sleep_duration = rand(6..10).hours

    wake_time = bedtime + sleep_duration.to_i.seconds
    sleep_record.update!(
      wake_time: wake_time
    )
  end
end

puts "Creating follow relationships..."
users.each do |user|
  follow_count = rand(1..3)
  users_to_follow = users.reject { |u| u == user }.sample(follow_count)

  users_to_follow.each do |followed_user|
    Follow.create!(
      follower: user,
      followed: followed_user
    )
  end
end

puts "Seed data created successfully!"

ActiveRecord::Base.connection.execute(
  "REFRESH MATERIALIZED VIEW weekly_sleep_records_summary"
)

puts "REFRESH MATERIALIZED VIEW weekly_sleep_records_summary successfully!"
