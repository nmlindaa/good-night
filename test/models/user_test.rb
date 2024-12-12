require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }

    it "is valid with a name" do
      expect(build(:user)).to be_valid
    end
  end

  describe "associations" do
    it "has many followers" do
      user = User.reflect_on_association(:followers)
      expect(user.macro).to eq(:has_many)
    end

    it "has many following" do
      user = User.reflect_on_association(:following)
      expect(user.macro).to eq(:has_many)
    end
  end
end
