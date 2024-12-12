require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { User.create(name: "John Doe") }
  let(:other_user) { User.create(name: "Jane Smith") }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "is not valid without a name" do
      user.name = nil
      expect(user).to_not be_valid
    end
  end

  describe "associations" do
    it "has many followers" do
      association = described_class.reflect_on_association(:followers)
      expect(association.macro).to eq :has_many
      expect(association.options[:source]).to eq :follower
      expect(association.options[:through]).to eq :follower_relationships
    end

    it "has many following" do
      association = described_class.reflect_on_association(:following)
      expect(association.macro).to eq :has_many
      expect(association.options[:source]).to eq :followed
      expect(association.options[:through]).to eq :following_relationships
    end
  end
end