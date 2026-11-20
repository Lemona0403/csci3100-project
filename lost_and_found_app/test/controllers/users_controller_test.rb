require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_registration_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      post user_registration_url, params: {
        user: {
          email: "new-user@example.com",
          name: "New User",
          role: "general",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_url
  end


  test "should show user" do
    sign_in @user
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    sign_in @user
    patch user_url(@user), params: { user: { email: @user.email, name: @user.name, password: @user.password, role: @user.role } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    sign_in @user
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
