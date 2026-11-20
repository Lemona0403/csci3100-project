require "test_helper"

class ClaimsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @claim = claims(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get claims_url
    assert_response :success
  end

  test "should get new" do
    get new_item_claim_url(@claim.item)
    assert_response :success
  end

  test "should create claim" do
    assert_difference("Claim.count") do
      post item_claims_url(@claim.item), params: { claim: { contact_info: @claim.contact_info, message: @claim.message, status: @claim.status } }
    end

    assert_redirected_to claim_url(Claim.last)
  end

  test "should show claim" do
    get claim_url(@claim)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:staff)
    get edit_claim_url(@claim)
    assert_response :success
  end

  test "should update claim" do
    sign_in users(:staff)
    patch claim_url(@claim), params: { claim: { contact_info: @claim.contact_info, message: @claim.message, status: @claim.status } }
    assert_redirected_to claim_url(@claim)
  end

  test "should destroy claim" do
    sign_in users(:staff)
    assert_difference("Claim.count", -1) do
      delete claim_url(@claim)
    end

    assert_redirected_to claims_url
  end
end
