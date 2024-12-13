require "rails_helper"

RSpec.describe Api::V1::FollowsController, type: :controller do
  describe "POST #create" do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    context "with valid parameters" do
      it "creates a new follow relationship" do
        expect {
          post :create, params: { follow: { follower_id: follower.id, followed_id: followed.id } }
        }.to change(Follow, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include(
          "follower_id" => follower.id,
          "followed_id" => followed.id
        )
      end
    end

    context "with invalid parameters" do
      it "does not create a follow relationship" do
        expect {
          post :create, params: { follow: { follower_id: nil, followed_id: nil } }
        }.not_to change(Follow, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:follow) { create(:follow) }

    context "when the follow relationship exists" do
      it "destroys the follow relationship" do
        expect {
          delete :destroy, params: { follow: { follower_id: follow.follower_id, followed_id: follow.followed_id } }
        }.to change(Follow, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when the follow relationship does not exist" do
      it "returns not found status" do
        delete :destroy, params: { follow: { follower_id: 999, followed_id: 1000 } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
