require "rails_helper"

RSpec.describe Api::V1::FollowingSleepRecordsController, type: :controller do
  describe "GET #index" do
    let(:user) { create(:user) }
    let(:following1) { create(:user) }
    let(:following2) { create(:user) }

    before do
      create(:follow, follower: user, followed: following1)
      create(:follow, follower: user, followed: following2)
    end

    context "when user exists" do
      before do
        create(:sleep_record, :closed, user: following1, bed_time: 2.days.ago, wake_time: 2.days.ago + 8.hours)
        create(:sleep_record, :closed, user: following1, bed_time: 1.day.ago, wake_time: 1.day.ago + 7.hours)
        create(:sleep_record, :closed, user: following2, bed_time: 3.days.ago, wake_time: 3.days.ago + 7.5.hours)
        create(:sleep_record, :closed, user: following2, bed_time: 8.days.ago, wake_time: 8.days.ago + 8.hours + 20.minutes)

        create(:sleep_record, :closed, bed_time: 1.day.ago, wake_time: 1.day.ago + 7.hours + 40.minutes)
      end

      it "returns sleep records of followings within last week, sorted by duration" do
        get :index, params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Success")
        expect(json_response["sleep_records"].count).to eq(3)
        expect(json_response["sleep_records"].first["duration_minutes"]).to eq(480)
        expect(json_response["sleep_records"].last["duration_minutes"]).to eq(420)
      end

      it "paginates results" do
        get :index, params: { user_id: user.id, page: 1, per_page: 2 }

        json_response = JSON.parse(response.body)
        expect(json_response["sleep_records"].count).to eq(2)
      end
    end

    context "when user does not exist" do
      it "returns a not found error" do
        get :index, params: { user_id: 9999 }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("User not found")
      end
    end
  end
end
