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

  test "users can search their claims by item name and status" do
    get claims_url, params: { query: "Test item one", status: "pending" }

    assert_response :success
    assert_includes response.body, "Test item one"
    assert_not_includes response.body, "Test item two"
    assert_select "input[name='query'][value='Test item one']"
    assert_select "select[name='status']"
  end

  test "should get new" do
    @claim.item.update!(status: :available)
    get new_item_claim_url(@claim.item)
    assert_response :success
  end

  test "should create claim" do
    @claim.item.update!(status: :available)
    assert_difference("Claim.count") do
      post item_claims_url(@claim.item), params: { claim: { contact_info: @claim.contact_info, message: @claim.message, status: @claim.status } }
    end

    assert_redirected_to claim_url(Claim.last)
  end

  test "should show claim" do
    get claim_url(@claim)
    assert_response :success
  end

  test "general users do not see claim management controls" do
    get claim_url(@claim)

    assert_response :success
    assert_no_match(/Edit this claim|Destroy this claim|Approve claim|Reject claim/, response.body)
  end

  test "staff can review a pending claim" do
    sign_in users(:staff)
    get claim_url(@claim)

    assert_response :success
    assert_includes response.body, "Approve claim"
    assert_includes response.body, "Reject claim"
    assert_includes response.body, "Edit this claim"
    assert_includes response.body, "Destroy this claim"
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
