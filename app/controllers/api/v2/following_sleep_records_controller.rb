module Api
  module V2
    class FollowingSleepRecordsController < ApplicationController
      def index
        user = User.find(params[:user_id])
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i

        cache_key = "following_sleep_records_v2_#{user.id}_page_#{page}_per_#{per_page}"

        cached_data = Rails.cache.fetch(cache_key, expires_in: 1.minutes) do
          records = fetch_sleep_records(user, page, per_page)
          {
            sleep_records: records.to_a,
            total_pages: records.total_pages
          }
        end

        render json: {
          message: "Success",
          sleep_records: serialize_records(cached_data[:sleep_records]),
          page: page,
          total_pages: cached_data[:total_pages]
        }
      end

      private

      def fetch_sleep_records(user, page, per_page)
        recent_follow_changes = user.all_followings.where("updated_at >= ?", 1.hour.ago).select(:followed_id, :unfollowed_at)

        recent_follow_ids = recent_follow_changes.select { |f| f.unfollowed_at.nil? }.map(&:followed_id)
        recent_unfollow_ids = recent_follow_changes.select { |f| f.unfollowed_at.present? }.map(&:followed_id)

        WeeklySleepRecords.where("follower_id = :user_id OR user_id IN (:recent_follow_ids)",
                            user_id: user.id, recent_follow_ids: recent_follow_ids)
                          .where.not(user_id: recent_unfollow_ids)
                          .page(page).per(per_page)
      end

      def serialize_records(records)
        records.map do |record|
          {
            id: record.id,
            user_id: record.user_id,
            bed_time: record.bed_time,
            wake_time: record.wake_time,
            duration_minutes: record.duration_minutes
          }
        end
      end
    end
  end
end
