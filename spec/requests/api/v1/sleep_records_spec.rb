require 'rails_helper'

RSpec.describe Api::V1::SleepRecordsController, type: :controller do
  let(:user) { create(:user) }

  describe "GET #index" do
    it "returns a successful response" do
      get :index, params: { user_id: user.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns paginated sleep records" do
      15.times do |i|
        create(:sleep_record,
          user: user,
          bed_time: (15 - i).days.ago.beginning_of_day + 22.hours,
          wake_time: (14 - i).days.ago.beginning_of_day + 6.hours
        )
      end

      get :index, params: { user_id: user.id, page: 1, per_page: 10 }
      expect(JSON.parse(response.body)["sleep_records"].size).to eq(10)
      expect(JSON.parse(response.body)["total_pages"]).to eq(2)
    end
  end

  describe "POST #clock_in" do
    context "when user is not clocked in" do
      it "creates a new sleep record" do
        expect {
          post :clock_in, params: { user_id: user.id }
        }.to change(SleepRecord, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "when user is already clocked in" do
      before { create(:sleep_record, user: user, wake_time: nil) }

      it "returns an error" do
        post :clock_in, params: { user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("You're already clocked in.")
      end
    end
  end

  describe "PUT #clock_out" do
    context "when user has an open sleep record" do
      let!(:open_sleep_record) { create(:sleep_record, user: user, wake_time: nil) }

      it "updates the sleep record with wake time" do
        put :clock_out, params: { user_id: user.id }
        expect(response).to have_http_status(:ok)
        expect(open_sleep_record.reload.wake_time).to be_present
      end
    end

    context "when user has no open sleep record" do
      it "returns a not found error" do
        put :clock_out, params: { user_id: user.id }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("No open sleep record found")
      end
    end
  end
end
