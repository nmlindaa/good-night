require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }

    it "is valid with a name" do
      expect(build(:user)).to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:active_followings).conditions(unfollowed_at: nil).class_name("Follow").with_foreign_key("follower_id").dependent(:destroy) }
    it { should have_many(:following_users).through(:active_followings).source(:followed) }

    it { should have_many(:active_followers).conditions(unfollowed_at: nil).class_name("Follow").with_foreign_key("followed_id").dependent(:destroy) }
    it { should have_many(:follower_users).through(:active_followers).source(:follower) }

    it { should have_many(:all_followings).class_name("Follow").with_foreign_key("follower_id").dependent(:destroy) }
    it { should have_many(:all_followers).class_name("Follow").with_foreign_key("followed_id").dependent(:destroy) }

    it { should have_many(:sleep_records).dependent(:destroy) }
  end

  describe "following functionality" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    before do
      create(:follow, follower: user1, followed: user2)
      create(:follow, follower: user3, followed: user1)
      create(:follow, follower: user1, followed: user3, unfollowed_at: Time.current)
    end

    it "returns active followings" do
      expect(user1.following_users).to include(user2)
      expect(user1.following_users).not_to include(user3)
    end

    it "returns active followers" do
      expect(user1.follower_users).to include(user3)
      expect(user2.follower_users).to include(user1)
    end

    it "returns all followings including unfollowed" do
      expect(user1.all_followings.count).to eq(2)
      expect(user1.all_followings.pluck(:followed_id)).to include(user2.id, user3.id)
    end

    it "returns all followers including unfollowed" do
      expect(user1.all_followers.count).to eq(1)
      expect(user1.all_followers.first.follower).to eq(user3)
    end
  end
end
