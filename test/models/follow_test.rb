require "rails_helper"

RSpec.describe Follow, type: :model do
  let(:user1) { User.create(name: "John Doe") }
  let(:user2) { User.create(name: "Jane Smith") }

  describe "associations" do
    it "belongs to a follower" do
      association = described_class.reflect_on_association(:follower)
      expect(association.macro).to eq :belongs_to
      expect(association.class_name).to eq "User"
    end

    it "belongs to a followed user" do
      association = described_class.reflect_on_association(:followed)
      expect(association.macro).to eq :belongs_to
      expect(association.class_name).to eq "User"
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      follower = Follow.new(follower: user1, followed: user2)
      expect(follower).to be_valid
    end

    it "is not valid without a follower" do
      follower = Follow.new(followed: user2)
      expect(follower).to_not be_valid
    end

    it "is not valid without a followed user" do
      follower = Follow.new(follower: user1)
      expect(follower).to_not be_valid
    end

    it "does not allow a user to follow themselves" do
      follower = Follow.new(follower: user1, followed: user1)
      expect(follower).to_not be_valid
    end

    it "does not allow duplicate follows" do
      Follow.create(follower: user1, followed: user2)
      duplicate_follow = Follow.new(follower: user1, followed: user2)
      expect(duplicate_follow).to_not be_valid
    end
  end

  describe "scopes" do
    before do
      Follow.create(follower: user1, followed: user2)
    end

    it "returns followers for a user" do
      expect(Follow.where(followed: user2)).to exist
    end

    it "returns followed users for a user" do
      expect(Follow.where(follower: user1)).to exist
    end
  end

  describe "methods" do
    it "allows a user to follow another user" do
      expect {
        Follow.create(follower: user1, followed: user2)
      }.to change { Follow.count }.by(1)
    end

    it "allows a user to unfollow another user" do
      follower = Follow.create(follower: user1, followed: user2)
      expect {
        follower.destroy
      }.to change { Follow.count }.by(-1)
    end
  end
end
