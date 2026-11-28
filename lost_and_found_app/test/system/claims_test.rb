require "application_system_test_case"

class ClaimsTest < ApplicationSystemTestCase
  setup do
    @claim = claims(:one)
  end

  test "visiting the index" do
    sign_in_as(users(:one))
    visit claims_url
    assert_selector "h1", text: "My claims"
  end

  test "should create claim" do
    sign_in_as(users(:one))
    item = Item.create!(
      title: "System test claim item",
      description: "Created for a system claim",
      category: :clothing,
      status: :available,
      date_found: Time.current,
      facility: @claim.facility
    )
    visit item_url(item)
    click_on "Claim this item"

    fill_in "Contact info", with: "system-test@example.com"
    fill_in "Message", with: "I can identify this item"
    click_on "Create Claim"

    assert_text "Claim was successfully created"
  end

  test "staff can review claims without edit or destroy controls" do
    sign_in_as(users(:staff))
    visit claim_url(@claim)

    assert_button "Approve claim"
    assert_button "Reject claim"
    assert_no_link "Edit this claim"
    assert_no_button "Destroy this claim"
  end
end
