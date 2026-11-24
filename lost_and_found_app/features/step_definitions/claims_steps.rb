Given (/^a pending claim on "(.*)" by "(.*)"$/) do |title, email|
  item = Item.find_by!(title: title)
  user = User.find_by!(email: email)
  item.status = :claim_pending
  item.save!(validate: false)

  claim = Claim.find_or_initialize_by(item: item, user: user)
  claim.facility = item.facility
  claim.status = :pending
  claim.contact_info = "12345678"
  claim.message = "I would like to claim it"
  claim.save!
end

When (/^I claim item "(.*)" with contact "(.*)"$/) do |title, contact|
  item = Item.find_by!(title: title)
  visit new_item_claim_path(item)
  fill_in "Contact info", with: contact
  fill_in "Message", with: "I would like to claim it"
  click_button "Create Claim"
end

When (/^I try to claim "(.*)"$/) do |title|
  item = Item.find_by!(title: title)
  visit new_item_claim_path(item)
end

Then (/^I should be redirected to the item page$/) do
  expect(page).not_to have_field("Contact info")
  expect(page).not_to have_button("Create Claim")
end

When (/^I approve the claim for "(.*)"$/) do |title|
  item = Item.find_by!(title: title)
  claim = item.claims.where(status: :pending).order(:id).last!
  visit claim_path(claim)
  click_button "Approve"
end

When (/^I reject the claim for "(.*)"$/) do |title|
  item = Item.find_by!(title: title)
  claim = item.claims.where(status: :pending).order(:id).last!
  visit claim_path(claim)
  click_button "Reject"
end

Then (/^a claim for "(.*)" should have status "(.*)"$/) do |title, status|
  item = Item.find_by!(title: title)
  claim = item.claims.order(:id).last!
  expect(claim.status).to eq(status)
end

Then (/^the claim for "(.*)" should have status "(.*)"$/) do |title, status|
  item = Item.find_by!(title: title)
  claim = item.claims.order(:id).last!
  expect(claim.status).to eq(status)
end

When (/^I visit the claims page$/) do
  visit claims_path
end

Then (/^I should see a claim for "(.*)"$/) do |title|
  expect(page).to have_content(title)
end

Then (/^I should not see a claim for "(.*)"$/) do |title|
  expect(page).not_to have_content(title)
end

Then (/^the claim for "(.*)" should belong to "(.*)"$/) do |title, email|
  item = Item.find_by!(title: title)
  claim = item.claims.order(:id).last!
  expect(claim.user.email).to eq(email)
end