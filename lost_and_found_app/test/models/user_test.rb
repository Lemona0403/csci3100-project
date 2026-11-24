require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "accepts a password with at least three character types" do
    user = User.new(
      email: "strong-password@example.com",
      name: "Test User",
      role: :general,
      password: "Abcdefg1",
      password_confirmation: "Abcdefg1"
    )

    assert user.valid?, user.errors.full_messages.inspect
  end

  test "rejects a password shorter than eight characters" do
    user = User.new(
      email: "short-password@example.com",
      name: "Test User",
      role: :general,
      password: "Ab1!",
      password_confirmation: "Ab1!"
    )

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "rejects a password with fewer than three character types" do
    user = User.new(
      email: "weak-password@example.com",
      name: "Test User",
      role: :general,
      password: "abcdefgh1",
      password_confirmation: "abcdefgh1"
    )

    assert_not user.valid?
    assert user.errors[:password].any? { |error| error.include?("at least three") }
  end
end
