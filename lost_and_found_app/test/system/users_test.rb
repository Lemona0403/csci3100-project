require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h1", text: "Users"
  end

  test "login password visibility can be toggled" do
    visit new_user_session_url

    assert_selector "input#user_password[type='password']"
    click_button "Show password"
    assert_selector "input#user_password[type='text']"
    assert_button "Hide password"

    click_button "Hide password"
    assert_selector "input#user_password[type='password']"
  end

  test "should log in" do
    visit new_user_session_url
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    assert_text "Signed in as #{@user.name}"
  end

  test "should create user" do
    visit new_user_registration_url

    fill_in "Email", with: "system-created@example.com"
    fill_in "Name", with: "System Created User"
    select "General", from: "Role"
    fill_in "Password", with: "Password123!"
    fill_in "Password confirmation", with: "Password123!"
    click_button "Sign up"

    assert_text "Signed in as System Created User"
  end

  test "should update User" do
    sign_in_as(users(:staff))
    visit user_url(@user)
    click_on "Edit this user", match: :first

    fill_in "Password", with: "NewPassword123!"
    fill_in "Name", with: "Updated Test User"
    click_on "Update User"

    assert_text "User was successfully updated"
  end

  test "should destroy User" do
    sign_in_as(users(:staff))
    visit user_url(@user)
    click_button "Destroy this user"

    assert_text "User was successfully destroyed"
  end
end
