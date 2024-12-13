require "rails_helper"

RSpec.describe Follow, type: :model do
  describe "validations" do
    it "is valid with different users" do
      user1 = create(:user)
      user2 = create(:user)
      follow = build(:follow, follower: user1, followed: user2)
      expect(follow).to be_valid
    end

    it "is invalid if follower and followed are the same" do
      user = create(:user)
      follow = build(:follow, follower: user, followed: user)
      expect(follow).to_not be_valid
      expect(follow.errors.full_messages[0]).to include("can't follow themselves")
    end

    it "is invalid without a follower" do
      follow = build(:follow, follower: nil)
      expect(follow).to_not be_valid
    end

    it "is invalid without a followed" do
      follow = build(:follow, followed: nil)
      expect(follow).to_not be_valid
    end

    it "validates uniqueness of follower and followed combination" do
      user1 = create(:user)
      user2 = create(:user)
      Follow.create!(follower: user1, followed: user2)

      follow = build(:follow, follower: user1, followed: user2)
      expect(follow).to_not be_valid
    end
  end
end
