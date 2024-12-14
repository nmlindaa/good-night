require "rails_helper"

RSpec.describe Follow, type: :model do
  let(:follower) { create(:user) }
  let(:followed) { create(:user) }

  describe "validations" do
    it { should validate_presence_of(:follower_id) }
    it { should validate_presence_of(:followed_id) }
    it "should not allow a user to follow themselves" do
      follow = build(:follow, follower: follower, followed: follower)
      expect(follow).to be_invalid
      expect(follow.errors[:base]).to include("can't follow themselves")
    end

    it "should not allow duplicate active follows" do
      create(:follow, follower: follower, followed: followed)
      duplicate_follow = build(:follow, follower: follower, followed: followed)
      expect(duplicate_follow).to be_invalid
      expect(duplicate_follow.errors[:base]).to include("already following this user")
    end

    it "is valid with different users" do
      user1 = create(:user)
      user2 = create(:user)
      follow = build(:follow, follower: user1, followed: user2)
      expect(follow).to be_valid
    end

    it "is invalid without a follower" do
      follow = build(:follow, follower: nil)
      expect(follow).to_not be_valid
      expect(follow.errors[:follower]).to include("must exist")
    end

    it "is invalid without a followed" do
      follow = build(:follow, followed: nil)
      expect(follow).to_not be_valid
      expect(follow.errors[:followed]).to include("must exist")
    end

    it "validates uniqueness of follower and followed combination" do
      user1 = create(:user)
      user2 = create(:user)
      Follow.create!(follower: user1, followed: user2)

      follow = build(:follow, follower: user1, followed: user2)
      expect(follow).to_not be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:follower).class_name("User") }
    it { should belong_to(:followed).class_name("User") }
  end

  describe "scopes" do
    let!(:active_follow) { create(:follow, follower: follower, followed: followed) }
    let!(:unfollowed_follow) { create(:follow, follower: follower, followed: create(:user), unfollowed_at: Time.current) }

    it "active scope returns only active follows" do
      expect(Follow.active).to include(active_follow)
      expect(Follow.active).not_to include(unfollowed_follow)
    end

    it "unfollowed scope returns only unfollowed follows" do
      expect(Follow.unfollowed).to include(unfollowed_follow)
      expect(Follow.unfollowed).not_to include(active_follow)
    end
  end

  describe ".follow" do
    context "when following a new user" do
      it "creates a new follow record" do
        expect {
          Follow.follow(follower.id, followed.id)
        }.to change(Follow, :count).by(1)
      end
    end

    context "when refollowing an unfollowed user" do
      let!(:unfollowed) { create(:follow, follower: follower, followed: followed, unfollowed_at: 1.day.ago) }

      it "reactivates the existing follow record" do
        expect {
          Follow.follow(follower.id, followed.id)
        }.not_to change(Follow, :count)

        expect(unfollowed.reload.unfollowed_at).to be_nil
      end
    end

    context "when following a non-existent user" do
      it "raises an ActiveRecord::RecordNotFound error" do
        expect {
          Follow.follow(follower.id, -1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when creating an invalid follow" do
      it "raises an ActiveRecord::RecordInvalid error" do
        expect {
          Follow.follow(follower.id, follower.id)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe ".unfollow" do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    context "when the follow relationship exists" do
      let!(:follow) { create(:follow, follower: follower, followed: followed) }

      it "unfollows successfully" do
        expect(Follow).to receive(:find_by).with(follower_id: follower.id, followed_id: followed.id).and_return(follow)
        expect(follow).to receive(:unfollow!)

        result = Follow.unfollow(follower.id, followed.id)

        expect(result).to eq(follow)
      end

      it "locks the users" do
        expect(User).to receive(:lock).twice.and_call_original
        Follow.unfollow(follower.id, followed.id)
      end
    end

    context "when the follow relationship does not exist" do
      it "logs an error" do
        expect(Rails.logger).to receive(:error).with("Not following")

        result = Follow.unfollow(follower.id, followed.id)

        expect(result).to be_nil
      end
    end

    context "when a user does not exist" do
      it "logs and raises RecordNotFound error" do
        expect(Rails.logger).to receive(:error).with(/Failed to unfollow:/)
        expect {
          Follow.unfollow(follower.id, -1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when there is a RecordInvalid error" do
      before do
        allow_any_instance_of(Follow).to receive(:unfollow!).and_raise(ActiveRecord::RecordInvalid.new(Follow.new))
      end

      it "logs and raises RecordInvalid error" do
        create(:follow, follower: follower, followed: followed)

        expect(Rails.logger).to receive(:error).with(/Invalid unfollow attempt:/)
        expect {
          Follow.unfollow(follower.id, followed.id)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    it "uses a transaction" do
      expect(Follow).to receive(:transaction).and_yield
      Follow.unfollow(follower.id, followed.id)
    end
  end

  describe "#unfollow!" do
    let!(:follow) { create(:follow, follower: follower, followed: followed) }

    it "sets the unfollowed_at timestamp" do
      expect {
        follow.unfollow!
      }.to change { follow.unfollowed_at }.from(nil)
    end
  end

  describe "#refollow!" do
    let!(:unfollowed_follow) { create(:follow, follower: follower, followed: followed, unfollowed_at: 1.day.ago) }
    it "clears the unfollowed_at timestamp" do
      expect {
        unfollowed_follow.refollow!
      }.to change { unfollowed_follow.unfollowed_at }.to(nil)
    end
  end

  describe "transaction and locking" do
    it "uses a transaction and locks records" do
      expect(Follow).to receive(:transaction).and_yield
      expect(User).to receive(:lock).twice.and_call_original
      expect_any_instance_of(Follow).to receive(:with_lock).and_yield

      Follow.follow(follower.id, followed.id)
    end
  end

  describe "error logging" do
    context "when user is not found" do
      it "logs an error message" do
        expect(Rails.logger).to receive(:error).with(/Failed to follow: Couldn't find User/)

        expect {
          Follow.follow(follower.id, -1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when follow is invalid" do
      it "logs an error message" do
        expect(Rails.logger).to receive(:error).with(/Invalid follow attempt:/)

        expect {
          Follow.follow(follower.id, follower.id)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
