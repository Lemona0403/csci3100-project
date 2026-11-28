
Given (/^available item "(.*)" exists at "(.*)"$/) do |title, facility_name|
  facility = Facility.find_by!(name: facility_name)
  item = Item.find_or_initialize_by(title: title, facility: facility)
  item.description = "Seeded #{title}"
  item.category = :clothing
  item.status = :available
  item.date_found = Time.zone.parse("2026-01-10 12:00")
  item.save!
end

Then (/^item "(.*)" should have status "(.*)"$/) do |title, status|
  item = Item.find_by!(title: title)
  expect(item.status).to eq(status)
end

Then (/^I should see that the item cannot be claimed$/) do
  expect(page).to have_content(/not available/i)
end

Then (/^I should see item "(.*)"$/) do |title|
  expect(page).to have_content(title)
end
Then (/^I should not see item "(.*)"$/) do |title|
  expect(page).not_to have_content(title)
end

Then (/^I should see item information for "(.*)"$/) do |title|
  item = Item.find_by!(title: title)
  expect(page).to have_content("Item information")
  expect(page).to have_content(item.title)
  expect(page).to have_content(item.description)
  expect(page).to have_content(item.category.humanize)
  expect(page).not_to have_link(item.title, href: item_path(item))
end