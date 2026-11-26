require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

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

  test "login page includes password visibility toggle" do
    get new_user_session_url

    assert_response :success
    assert_select "input#user_password[type='password'][autocomplete='current-password']"
    assert_select "button[type='button'][data-action='password-visibility#toggle'][aria-pressed='false']",
                  text: "Show password"
  end

  test "remember me creates a persistent login cookie" do
    post user_session_url, params: {
      user: { email: @user.email, password: "password", remember_me: "1" }
    }

    assert_response :redirect
    assert_not_nil @user.reload.remember_created_at
    assert response.cookies["remember_user_token"].present?
    remember_cookie_header = Array(response.headers["Set-Cookie"]).find do |cookie|
      cookie.start_with?("remember_user_token=")
    end
    assert_match(/expires=/i, remember_cookie_header)
  end

  test "signing out invalidates the remember me token" do
    post user_session_url, params: {
      user: { email: @user.email, password: "password", remember_me: "1" }
    }
    assert_not_nil @user.reload.remember_created_at

    delete destroy_user_session_url

    assert_response :redirect
    assert_nil @user.reload.remember_created_at
  end

  test "locks account after five failed sign in attempts" do
    5.times do
      post user_session_url, params: {
        user: { email: @user.email, password: "Incorrect1!" }
      }
    end

    assert @user.reload.access_locked?
    assert_equal 5, @user.failed_attempts
    assert_equal 3.minutes, Devise.unlock_in
    assert_equal I18n.t("devise.failure.locked_with_time", minutes: 3, seconds: 0), flash[:alert]
  end

  test "warns of the last attempt on the fourth failed sign in" do
    4.times do
      post user_session_url, params: {
        user: { email: @user.email, password: "Incorrect1!" }
      }
    end

    assert_equal 4, @user.reload.failed_attempts
    assert_equal I18n.t("devise.failure.last_attempt"), flash[:alert]
  end

  test "shows the remaining lock time on a locked account" do
    travel_to(Time.zone.local(2026, 1, 1, 12)) do
      5.times do
        post user_session_url, params: {
          user: { email: @user.email, password: "Incorrect1!" }
        }
      end

      @user.update_column(:locked_at, 2.minutes.ago)
      post user_session_url, params: {
        user: { email: @user.email, password: "Incorrect1!" }
      }

      assert_equal I18n.t("devise.failure.locked_with_time", minutes: 1, seconds: 0), flash[:alert]
    end
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      post user_registration_url, params: {
        user: {
          email: "new-user@example.com",
          name: "New User",
          role: "general",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end
    assert_redirected_to root_url
  end

  test "rejects registration with an identical account name" do
    assert_no_difference("User.count") do
      post user_registration_url, params: {
        user: {
          email: "duplicate-name@example.com",
          name: users(:one).name,
          role: "general",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_response :unprocessable_content
    assert_includes response.body, "has already been taken"
  end

  test "allows registration with an account name that differs only by case" do
    assert_difference("User.count", 1) do
      post user_registration_url, params: {
        user: {
          email: "case-different-name@example.com",
          name: users(:one).name.swapcase,
          role: "general",
          password: "Password123!",
          password_confirmation: "Password123!"
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
