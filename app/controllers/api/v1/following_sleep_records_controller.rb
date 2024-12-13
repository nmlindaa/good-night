module Api
  module V1
    class FollowingSleepRecordsController < ApplicationController
      # GET /following_sleep_records
      def index
        user = User.find_by(id: params[:user_id])
        return render json: { error: "User not found" }, status: :not_found unless user

        records = SleepRecord.where(user_id: user.following_ids)
                             .where("bed_time >= ?", 1.week.ago)
                             .closed
                             .order(duration_minutes: :desc)
                             .page(params[:page] || 1)
                             .per(params[:per_page] || 10)

        render json: { message: "Success", sleep_records: records }, status: :ok
      end
    end
  end
end
