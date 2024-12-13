require "rails_helper"

RSpec.describe Api::V2::FollowingSleepRecordsController, type: :controller do
  describe "GET #index" do
    let(:user) { create(:user) }
    let(:followed_user1) { create(:user) }
    let(:followed_user2) { create(:user) }

    before do
      create(:follow, follower: user, followed: followed_user1)
      create(:follow, follower: user, followed: followed_user2)

      2.times do |i|
        create(:sleep_record,
          user: followed_user1,
          bed_time: (7 - i).days.ago.beginning_of_day + 22.hours,
          wake_time: (6 - i).days.ago.beginning_of_day + 6.hours
        )
      end

      create(:sleep_record,
          user: followed_user2,
          bed_time: 2.days.ago.beginning_of_day + 22.hours,
          wake_time: 1.days.ago.beginning_of_day + 6.hours
        )

      WeeklySleepRecordsSummary.refresh
    end

    it "returns a successful response" do
      get :index, params: { user_id: user.id }
      expect(response).to have_http_status(:success)
    end

    it "returns the correct number of sleep records" do
      get :index, params: { user_id: user.id, per_page: 2 }
      json_response = JSON.parse(response.body)
      expect(json_response["sleep_records"].length).to eq(2)
    end

    it "returns sleep records with correct attributes" do
      get :index, params: { user_id: user.id }
      json_response = JSON.parse(response.body)

      expect(json_response["message"]).to eq("Success")
      expect(json_response["sleep_records"]).to all(include(
        "id", "user_id", "bed_time", "wake_time", "duration_minutes"
      ))
    end

    it "paginates the results" do
      get :index, params: { user_id: user.id, page: 2, per_page: 2 }
      json_response = JSON.parse(response.body)
      expect(json_response["sleep_records"].length).to eq(1)
    end

    it "uses default pagination when not specified" do
      get :index, params: { user_id: user.id }
      json_response = JSON.parse(response.body)
      expect(json_response["sleep_records"].length).to eq(3)
    end
  end
end
