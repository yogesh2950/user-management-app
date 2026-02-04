require "test_helper"

class UserTest < ActiveSupport::TestCase

  test "should not save user without name" do
    user = User.new(email: "yogesh@gmail.com", password: "1234567", mobile_no: 9876543210, city: "Pune")
    # assert_not = is used to verify that specific condition is not true or is false
    assert user.valid?, user.errors.full_messages
  end

  test "should not save user without email" do
    user = User.new(email: nil)
    assert_not user.save, "Saved the user without an email"
  end

  test "should not save user without password" do
    user = User.new
    assert_not user.save, "Saved the user without an password"
  end

  test "should not save user without mobile_no" do
    user = User.new
    assert_not user.save, "Saved the user without an mobile_no"
  end

  test "should save the user without city" do
    user = User.new
    assert_not user.save, "Required city"
  end

  test "should save the user within password renge" do
    user = User.new
    assert_not user.save, "Saved the user password outside renge"
  end


end
