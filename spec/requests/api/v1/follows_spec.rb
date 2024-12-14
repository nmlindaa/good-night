require "rails_helper"

RSpec.describe Api::V1::FollowsController, type: :controller do
  describe "POST #follow" do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }
    let(:valid_params) { { follow: { follower_id: follower.id, followed_id: followed.id } } }

    context "when the follow is successful" do
      let(:follow_result) { double(persisted?: true) }

      before do
        allow(Follow).to receive(:follow).and_return(follow_result)
      end

      it "returns a success message" do
        post :follow, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ "message" => "Success" })
      end
    end

    context "when the follow is unsuccessful" do
      let(:follow_result) { double(persisted?: false, errors: [ "Error message" ]) }

      before do
        allow(Follow).to receive(:follow).and_return(follow_result)
      end

      it "returns error messages" do
        post :follow, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "errors" => [ "Error message" ] })
      end
    end

    context "when a user is not found" do
      before do
        allow(Follow).to receive(:follow).and_raise(ActiveRecord::RecordNotFound.new("User not found"))
      end

      it "returns a not found status" do
        post :follow, params: valid_params
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ "errors" => [ "User not found" ] })
      end
    end
  end

  describe "PATCH #unfollow" do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }
    let(:valid_params) { { follow: { follower_id: follower.id, followed_id: followed.id } } }

    context "when the unfollow is successful" do
      let(:unfollow_result) { double(persisted?: true) }

      before do
        allow(Follow).to receive(:unfollow).and_return(unfollow_result)
      end

      it "returns a success message" do
        post :unfollow, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ "message" => "Success" })
      end
    end

    context "when the unfollow is unsuccessful" do
      let(:unfollow_result) { double(persisted?: false, errors: [ "Error message" ]) }

      before do
        allow(Follow).to receive(:unfollow).and_return(unfollow_result)
      end

      it "returns error messages" do
        post :unfollow, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "errors" => [ "Error message" ] })
      end
    end

    context "when a user is not found" do
      before do
        allow(Follow).to receive(:unfollow).and_raise(ActiveRecord::RecordNotFound.new("User not found"))
      end

      it "returns a not found status" do
        post :unfollow, params: valid_params
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ "errors" => [ "User not found" ] })
      end
    end
  end
end
