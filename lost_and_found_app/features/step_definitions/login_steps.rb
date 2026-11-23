Given (/^I am not logged in$/) do
  logout(:user) if respond_to?(:logout)
end

Given (/^I am logged in as "(.*)"$/) do |email|
  user = User.find_by!(email: email)
  login_as(user, scope: :user)
end

When (/^I visit the items page$/) do
  visit items_path
end

Then (/^I should be on the login page$/) do
  expect(page).to have_current_path(new_user_session_path)
end