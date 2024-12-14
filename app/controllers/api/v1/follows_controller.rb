module Api
  module V1
    class FollowsController < ApplicationController
      def follow
        follow = Follow.follow(follow_params[:follower_id], follow_params[:followed_id])
        if follow.persisted?
          render json: { message: "Successfully followed user" }, status: :ok
        else
          render json: { errors: follow.errors }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: [ e.message ] }, status: :not_found
      end

      def unfollow
        unfollow = Follow.unfollow(follow_params[:follower_id], follow_params[:followed_id])
        if unfollow.persisted?
          render json: { message: "Successfully unfollowed user" }, status: :ok
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
