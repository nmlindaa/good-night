module Api
  module V1
    class FollowsController < ApplicationController
      def follow
        follow = Follow.follow(follow_params[:follower_id], follow_params[:following_id])
        if follow.success?
          render json: { message: "Success" }, status: :ok
        else
          render json: { errors: follow.errors }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: [ e.message ] }, status: :not_found
      end

      def unfollow
        unfollow = Follow.unfollow(follow_params[:follower_id], follow_params[:following_id])
        if unfollow.success?
          render json: { message: "Success" }, status: :ok
        else
          render json: { errors: unfollow.errors }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: [ e.message ] }, status: :not_found
      end

      private

      def follow_params
        params.require(:follow).permit(:follower_id, :followed_id)
      end
    end
  end
end
