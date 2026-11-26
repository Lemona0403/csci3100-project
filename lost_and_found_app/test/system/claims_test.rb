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
    @claim.item.update!(status: :available)
    visit item_url(@claim.item)
    click_on "Claim this item"

    fill_in "Contact info", with: "system-test@example.com"
    fill_in "Message", with: "I can identify this item"
    click_on "Create Claim"

    assert_text "Claim was successfully created"
  end

  test "should update Claim" do
    sign_in_as(users(:staff))
    visit claim_url(@claim)
    click_on "Edit this claim", match: :first

    fill_in "Contact info", with: "updated-system-test@example.com"
    fill_in "Message", with: "Updated claim message"
    click_on "Update Claim"

    assert_text "Claim was successfully updated"
  end

  test "should destroy Claim" do
    sign_in_as(users(:staff))
    visit claim_url(@claim)
    click_button "Destroy this claim"

    assert_text "Claim was successfully destroyed"
  end
end
