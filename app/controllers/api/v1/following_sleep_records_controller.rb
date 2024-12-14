module Api
  module V1
    class FollowingSleepRecordsController < ApplicationController
      def index
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        user = User.find_by(id: params[:user_id])
        return render json: { error: "User not found" }, status: :not_found unless user

        records = SleepRecord.where(user_id: user.active_followings.map(&:followed_id))
                             .where("bed_time >= ?", 1.week.ago)
                             .closed
                             .order(duration_minutes: :desc)
                             .page(page)
                             .per(per_page)

        render json: { message: "Success", sleep_records: records, page: page, total_pages: records.total_pages }, status: :ok
      end
    end
  end
end
