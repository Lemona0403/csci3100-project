require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    sign_in users(:staff) # Sign in as a staff user for testing
  end

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "staff can search items and filter by category and status" do
    get items_url, params: {
      query: "Test item one",
      category: "water_bottle",
      status: "claim_pending"
    }

    assert_response :success
    assert_includes response.body, "Test item one"
    assert_not_includes response.body, "Test item two"
    assert_select "input[name='query'][value='Test item one']"
    assert_select "select[name='category']"
    assert_select "select[name='status']"
  end

  test "general users can filter available items by facility and category" do
    sign_out :user
    sign_in users(:one)
    @item.update!(status: :available)

    get items_url, params: { facility_id: @item.facility_id, category: "water_bottle" }

    assert_response :success
    assert_select "select[name='facility_id']"
    assert_select "select[name='category']"
    assert_select "select[name='status']", count: 0
    assert_includes response.body, "Test item one"
  end

  test "should redirect to sign in when logged out" do
    sign_out :user

    get items_url
    assert_redirected_to new_user_session_url

    get item_url(@item)
    assert_redirected_to new_user_session_url
  end

  test "should get new" do
    get new_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference("Item.count") do
      post items_url, params: { item: { category: @item.category, date_found: @item.date_found, description: @item.description, title: @item.title } }
    end

    assert_redirected_to item_url(Item.last)
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch item_url(@item), params: { item: { category: @item.category, date_found: @item.date_found, description: @item.description, title: @item.title } }
    assert_redirected_to item_url(@item)
  end

  test "should destroy item" do
    assert_difference("Item.count", -1) do
      delete item_url(@item)
    end

    assert_redirected_to items_url
  end
end
