module Api
  module V2
    class FollowingSleepRecordsController < ApplicationController
      def index
        user = User.find(params[:user_id])
        page = params[:page] || 1
        per_page = params[:per_page] || 10

        records = WeeklySleepRecordsSummary.where(follower_id: user.id)
                                           .page(page).per(per_page)

        render json: {
          message: "Success",
          sleep_records: records.map do |record|
            {
              id: record.id,
              user_id: record.user_id,
              bed_time: record.bed_time,
              wake_time: record.wake_time,
              duration_minutes: record.duration_minutes
            }
          end,
          page: page,
          total_pages: records.total_pages
        }
      end
    end
  end
end
