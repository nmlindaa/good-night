module Api
  module V1
    class FollowsController < ApplicationController
      def create
        follow = Follow.new(follow_params)
        if follow.save
          render json: follow, status: :created
        else
          render json: { errors: follow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        follow = Follow.find_by(follow_params)
        if follow
          follow.destroy
          head :no_content
        else
          head :not_found
        end
      end

      private

      def follow_params
        params.require(:follow).permit(:follower_id, :followed_id)
      end
    end
  end
end
