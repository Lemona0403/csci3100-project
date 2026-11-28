require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    sign_in users(:staff) # Sign in as a staff user for testing
  end

  test "should get index" do
    get items_url

    assert_response :success
    assert_select "a", text: "New item", count: 1
  end

  test "paginates filtered items ten per page and preserves filters" do
    12.times do |index|
      Item.create!(
        title: "Pagination item #{index + 1}",
        description: "Pagination test",
        category: :clothing,
        status: :available,
        date_found: Time.current,
        facility: @item.facility
      )
    end

    today = Date.current.iso8601
    filters = {
      query: "Pagination item",
      category: "clothing",
      status: "available",
      sort: "oldest",
      date_from: today,
      date_to: today
    }
    get items_url, params: filters

    assert_response :success
    assert_select "#items > div", count: 10
    next_link = css_select("nav[aria-label='Item pages'] a").find { |link| link.text == "Next" }
    assert next_link
    assert_includes next_link["href"], "query=Pagination"
    assert_includes next_link["href"], "category=clothing"
    assert_includes next_link["href"], "status=available"
    assert_includes next_link["href"], "sort=oldest"
    assert_includes next_link["href"], "date_from=#{today}"
    assert_includes next_link["href"], "date_to=#{today}"
    assert_includes next_link["href"], "page=2"
    assert_select "nav[aria-label='Item pages'] input[type='number'][name='page'][value='1'][min='1'][max='2']"
    assert_select "nav[aria-label='Item pages'] input[type='hidden'][name='query'][value='Pagination item']"
    assert_select "nav[aria-label='Item pages'] input[type='hidden'][name='sort'][value='oldest']"
    assert_select "nav[aria-label='Item pages'] input[type='hidden'][name='date_from'][value='#{today}']"

    get items_url, params: filters.merge(page: 2)

    assert_response :success
    assert_select "#items > div", count: 2
    assert_select "nav[aria-label='Item pages'] span", text: "Page 2 of 2"
    assert_select "nav[aria-label='Item pages'] input[type='number'][name='page'][value='2']"
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
    assert_select "select[name='sort'] option[selected='selected'][value='newest']"
    assert_select "input[name='date_from'][type='date']"
    assert_select "input[name='date_to'][type='date']"
  end

  test "filters items by inclusive date-found range" do
    before_range = create_item("Date range before", Time.zone.local(2026, 3, 9, 23, 59, 59))
    start_boundary = create_item("Date range start", Time.zone.local(2026, 3, 10, 0, 0, 0))
    end_boundary = create_item("Date range end", Time.zone.local(2026, 3, 11, 23, 59, 59))
    after_range = create_item("Date range after", Time.zone.local(2026, 3, 12, 0, 0, 0))

    get items_url, params: {
      query: "Date range",
      date_from: "2026-03-10",
      date_to: "2026-03-11"
    }

    assert_response :success
    assert_includes response.body, start_boundary.title
    assert_includes response.body, end_boundary.title
    assert_not_includes response.body, before_range.title
    assert_not_includes response.body, after_range.title
    assert_select "input[name='date_from'][value='2026-03-10']"
    assert_select "input[name='date_to'][value='2026-03-11']"
  end

  test "rejects an invalid date range without showing unfiltered items" do
    create_item("Date range test", Time.current)

    get items_url, params: {
      query: "Date range",
      date_from: "2026-03-12",
      date_to: "2026-03-10"
    }

    assert_response :success
    assert_select "#items > div", count: 0
    assert_includes response.body, "Start date must be on or before end date."
  end

  test "items default to newest date found and can be sorted oldest first" do
    oldest = Item.create!(
      title: "Sort item oldest",
      description: "Older item",
      category: :clothing,
      status: :available,
      date_found: 1.day.ago,
      facility: @item.facility
    )
    newest = Item.create!(
      title: "Sort item newest",
      description: "Newer item",
      category: :clothing,
      status: :available,
      date_found: Time.current,
      facility: @item.facility
    )

    get items_url, params: { query: "Sort item" }

    assert_response :success
    assert_equal ["item_#{newest.id}", "item_#{oldest.id}"],
                 css_select("#items > div").map { |element| element["id"] }

    get items_url, params: { query: "Sort item", sort: "oldest" }

    assert_response :success
    assert_equal ["item_#{oldest.id}", "item_#{newest.id}"],
                 css_select("#items > div").map { |element| element["id"] }
    assert_select "select[name='sort'] option[selected='selected'][value='oldest']"
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

  private

  def create_item(title, date_found)
    Item.create!(
      title: title,
      description: "Date range test",
      category: :clothing,
      status: :available,
      date_found: date_found,
      facility: @item.facility
    )
  end
end
