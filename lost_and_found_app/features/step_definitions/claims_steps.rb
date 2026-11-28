Given (/^(?:a|an) (pending|approved|rejected) claim on "(.*)" by "(.*)"$/) do |status, title, email|
  item = Item.find_by!(title: title)
  user = User.find_by!(email: email)
  item.status = { "pending" => :claim_pending, "approved" => :claimed, "rejected" => :available }.fetch(status)
  item.save!(validate: false)

  claim = Claim.find_or_initialize_by(item: item, user: user)
  claim.facility = item.facility
  claim.status = :pending
  claim.contact_info = "12345678"
  claim.message = "I would like to claim it"
  claim.save!
  claim.update!(status: status) unless status == "pending"
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

Then (/^I should be redirected to the items page$/) do
  expect(page).not_to have_field("Contact info")
  expect(page).not_to have_button("Create Claim")
end

When (/^I approve the claim for "(.*)"$/) do |title|
  item = Item.find_by!(title: title)
  claim = item.claims.where(status: :pending).order(:id).last!
  visit claim_path(claim)
  expect(page).to have_button("Approve claim")
  expect(page).to have_button("Reject claim")
  click_button "Approve claim"
end

When (/^I reject the claim for "(.*)"$/) do |title|
  item = Item.find_by!(title: title)
  claim = item.claims.where(status: :pending).order(:id).last!
  visit claim_path(claim)
  expect(page).to have_button("Approve claim")
  expect(page).to have_button("Reject claim")
  click_button "Reject claim"
end

When (/^I view the claim for "(.*)"$/) do |title|
  item = Item.find_by!(title: title)
  claim = item.claims.where(status: :pending).order(:id).last!
  visit claim_path(claim)
end

Then (/^I should see claim status "(.*)"$/) do |status|
  expect(page).to have_content(status.humanize)
end

Then (/^I should not see claim review controls$/) do
  expect(page).not_to have_button("Approve claim")
  expect(page).not_to have_button("Reject claim")
  expect(page).not_to have_link("Edit this claim")
  expect(page).not_to have_button("Destroy this claim")
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

When (/^I filter claims by "(pending|approved|rejected)"$/) do |status|
  select status.humanize, from: "Status"
  click_button "Search"
end

Then (/^the claim status filter should default to pending$/) do
  expect(page).to have_select("Status", selected: "Pending")
  expect(page.find_field("Status").all("option").map(&:text)).to eq(%w[Pending Approved Rejected])
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