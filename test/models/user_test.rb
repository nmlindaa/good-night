require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "should have valid fixtures" do
    assert users(:john).valid?
    assert users(:jane).valid?
    assert users(:bob).valid?
  end

  test "should have three users" do
    assert_equal 3, User.count
  end
end
