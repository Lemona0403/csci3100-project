require "test_helper"

class ClaimsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @claim = claims(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get claims_url

    assert_response :success
    assert_select "select[name='sort'] option[selected='selected'][value='latest']"
    assert_select "input[name='submitted_from'][type='date']"
    assert_select "input[name='submitted_to'][type='date']"
    assert_select "a", text: "Browse items to claim", count: 0
  end

  test "users can search their claims by item name and status" do
    get claims_url, params: { query: "Test item one", status: "pending" }

    assert_response :success
    assert_includes response.body, "Test item one"
    assert_not_includes response.body, "Test item two"
    assert_select "input[name='query'][value='Test item one']"
    assert_select "select[name='status']"
  end

  test "paginates filtered claims ten per page and preserves filters" do
    sign_in users(:staff)
    @claim.update_column(:created_at, Time.zone.local(2026, 3, 10, 0, 0, 0))
    12.times do |index|
      create_claim(submitted_at: Time.zone.local(2026, 3, 10, 0, index, 0))
    end
    filters = {
      query: "Test item one",
      status: "pending",
      sort: "earliest",
      submitted_from: "2026-03-10",
      submitted_to: "2026-03-11"
    }

    get claims_url, params: filters

    assert_response :success
    assert_select "#claims > div", count: 10
    next_link = css_select("nav[aria-label='Claim pages'] a").find { |link| link.text == "Next" }
    assert next_link
    assert_includes next_link["href"], "query=Test"
    assert_includes next_link["href"], "status=pending"
    assert_includes next_link["href"], "sort=earliest"
    assert_includes next_link["href"], "submitted_from=2026-03-10"
    assert_includes next_link["href"], "submitted_to=2026-03-11"
    assert_includes next_link["href"], "page=2"
    assert_select "nav[aria-label='Claim pages'] input[type='number'][name='page'][value='1'][min='1'][max='2']"

    get claims_url, params: filters.merge(page: 2)

    assert_response :success
    assert_select "#claims > div", count: 3
    assert_select "nav[aria-label='Claim pages'] span", text: "Page 2 of 2"
    assert_select "nav[aria-label='Claim pages'] input[type='number'][name='page'][value='2']"

    get claims_url, params: filters.merge(page: 0)

    assert_response :success
    assert_select "#claims > div", count: 10
    assert_select "nav[aria-label='Claim pages'] span", text: "Page 1 of 2"
    assert_select "nav[aria-label='Claim pages'] input[type='number'][name='page'][value='1']"

    get claims_url, params: filters.merge(page: 99)

    assert_response :success
    assert_select "#claims > div", count: 3
    assert_select "nav[aria-label='Claim pages'] span", text: "Page 2 of 2"
  end

  test "claims default to latest submission and can be sorted earliest within pending-first staff groups" do
    sign_in users(:staff)
    pending_old = claims(:one)
    pending_new = claims(:two)
    approved_new = create_claim(submitted_at: Time.zone.local(2026, 3, 12, 12))
    approved_new.update!(status: :approved)
    pending_old.update_column(:created_at, Time.zone.local(2026, 3, 10, 12))
    pending_new.update_column(:created_at, Time.zone.local(2026, 3, 11, 12))

    get claims_url

    assert_response :success
    assert_equal ["claim_#{pending_new.id}", "claim_#{pending_old.id}", "claim_#{approved_new.id}"],
                 css_select("#claims > div").map { |element| element["id"] }

    get claims_url, params: { sort: "earliest" }

    assert_response :success
    assert_equal ["claim_#{pending_old.id}", "claim_#{pending_new.id}", "claim_#{approved_new.id}"],
                 css_select("#claims > div").map { |element| element["id"] }
    assert_select "select[name='sort'] option[selected='selected'][value='earliest']"
  end

  test "filters claims by inclusive submitted date range" do
    sign_in users(:staff)
    start_claim = claims(:one)
    end_claim = claims(:two)
    start_claim.update_column(:created_at, Time.zone.local(2026, 3, 10, 0, 0, 0))
    end_claim.update_column(:created_at, Time.zone.local(2026, 3, 11, 23, 59, 59))
    before_range = create_claim(submitted_at: Time.zone.local(2026, 3, 9, 23, 59, 59))
    after_range = create_claim(submitted_at: Time.zone.local(2026, 3, 12, 0, 0, 0))

    get claims_url, params: {
      submitted_from: "2026-03-10",
      submitted_to: "2026-03-11"
    }

    assert_response :success
    assert_equal ["claim_#{end_claim.id}", "claim_#{start_claim.id}"],
                 css_select("#claims > div").map { |element| element["id"] }
    assert_not_includes response.body, "claim_#{before_range.id}"
    assert_not_includes response.body, "claim_#{after_range.id}"
    assert_select "input[name='submitted_from'][value='2026-03-10']"
    assert_select "input[name='submitted_to'][value='2026-03-11']"
  end

  test "rejects invalid submitted date ranges without showing unfiltered claims" do
    get claims_url, params: {
      submitted_from: "2026-03-12",
      submitted_to: "2026-03-10"
    }

    assert_response :success
    assert_select "#claims > div", count: 0
    assert_includes response.body, "Submitted start date must be on or before end date."
  end

  test "rejects malformed submitted dates without showing unfiltered claims" do
    get claims_url, params: { submitted_from: "not-a-date" }

    assert_response :success
    assert_select "#claims > div", count: 0
    assert_includes response.body, "Enter a valid submitted start date."
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

  private

  def create_claim(submitted_at:)
    claim = Claim.create!(
      contact_info: "submitted-date@example.com",
      message: "Submitted date test",
      facility: @claim.facility,
      user: users(:one),
      item: @claim.item,
      status: :pending
    )
    claim.update_column(:created_at, submitted_at)
    claim
  end
end
