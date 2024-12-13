# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_12_13_184653) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "follows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "follower_id"
    t.uuid "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
  end

  create_table "sleep_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.datetime "bed_time", null: false
    t.datetime "wake_time"
    t.integer "duration_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bed_time", "duration_minutes"], name: "index_sleep_records_on_bed_time_and_duration_minutes"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "sleep_records", "users"

  create_view "weekly_sleep_records_summary", materialized: true, sql_definition: <<-SQL
      SELECT sr.id,
      sr.user_id,
      f.follower_id,
      sr.bed_time,
      sr.wake_time,
      sr.duration_minutes
     FROM (sleep_records sr
       JOIN follows f ON ((sr.user_id = f.followed_id)))
    WHERE ((sr.bed_time >= (now() - 'P7D'::interval)) AND (sr.wake_time IS NOT NULL))
    ORDER BY sr.duration_minutes DESC;
  SQL
  add_index "weekly_sleep_records_summary", ["follower_id", "user_id"], name: "index_weekly_sleep_records_summary"

end
