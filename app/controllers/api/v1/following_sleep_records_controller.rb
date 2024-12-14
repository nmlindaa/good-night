module Api
  module V1
    class FollowingSleepRecordsController < ApplicationController
      def index
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        user = User.find_by(id: params[:user_id])
        return render json: { error: "User not found" }, status: :not_found unless user

        cache_key = "following_sleep_records_v1_#{user.id}_page_#{page}_per_#{per_page}"

        cached_data = Rails.cache.fetch(cache_key, expires_in: 1.minutes) do
          records = fetch_sleep_records(user, page, per_page)
          {
            sleep_records: records.to_a,
            total_pages: records.total_pages
          }
        end

        render json: {
          message: "Success",
          sleep_records: cached_data[:sleep_records],
          page: page,
          total_pages: cached_data[:total_pages]
        }, status: :ok
      end

      private

      def fetch_sleep_records(user, page, per_page)
        SleepRecord.where(user_id: user.active_followings.map(&:followed_id))
                   .where("bed_time >= ?", 1.week.ago)
                   .closed
                   .order(duration_minutes: :desc)
                   .page(page)
                   .per(per_page)
      end
    end
  end
end
