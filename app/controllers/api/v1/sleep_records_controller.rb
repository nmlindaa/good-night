module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user
      before_action :set_open_sleep_record, only: :clock_out

      # GET /sleep_records
      # Returns all clocked-in times for the current user, ordered by created_at
      def index
        sleep_records = @user.sleep_records
                              .order(created_at: :desc)
                              .page(params[:page] || 1)
                              .per(params[:per_page] || 10)
        render json: sleep_records, meta: { total_pages: sleep_records.total_pages }, status: :ok
      end

      # POST /sleep_records/clock_in
      # Logs bed time for the current user
      def clock_in
        if @user.sleep_records.where(wake_time: nil).exists?
          render json: { error: "You're already clocked in." }, status: :unprocessable_entity
          return
        end

        sleep_record = @user.sleep_records.new(bed_time: Time.zone.now)
        if sleep_record.save
          render json: { message: "Successfully clocked in", sleep_record: sleep_record }, status: :created
        else
          render json: { error: sleep_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /sleep_records/clock_out
      # Logs wake time for the current user
      def clock_out
        if @open_sleep_record.update(wake_time: Time.zone.now)
          render json: { message: "Successfully clocked out", sleep_record: @open_sleep_record }, status: :ok
        else
          render json: { error: @open_sleep_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_open_sleep_record
        @open_sleep_record = @user.sleep_records.where(wake_time: nil).order(created_at: :desc).first
        unless @open_sleep_record
          render json: { error: "No open sleep record found" }, status: :not_found
        end
      end

      def set_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
