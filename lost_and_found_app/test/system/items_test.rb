require "application_system_test_case"
require "base64"
require "tempfile"

class ItemsTest < ApplicationSystemTestCase
  setup do
    @item = items(:one)
  end

  test "visiting the index" do
    sign_in_as(users(:staff))
    visit items_url
    assert_selector "h1", text: "Items"
  end

  test "should create item" do
    sign_in_as(users(:staff))
    visit items_url
    click_link "New item", match: :first

    fill_in "Title", with: "System test item"
    fill_in "Description", with: "Created by a system test"
    find("#item_category").select("Water bottle")
    page.execute_script(
      "document.getElementById('item_date_found').value = arguments[0]",
      @item.date_found.strftime("%Y-%m-%dT%H:%M")
    )

    Tempfile.create(["system-test-photo", ".png"]) do |photo|
      photo.binmode
      photo.write(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jz8cAAAAASUVORK5CYII="))
      photo.flush
      attach_file "Photo", photo.path

      assert_selector "img[alt='Selected photo preview']"
      click_on "Create Item"

      assert_text "Item was successfully created"
      assert_selector "img[alt='Photo of System test item']"
    end
  end

  test "should update Item" do
    sign_in_as(users(:staff))
    visit item_url(@item)
    click_on "Edit this item", match: :first

    find("#item_category").select(@item.category.humanize)
    fill_in "Date found", with: @item.date_found.strftime("%Y-%m-%dT%H:%M")
    fill_in "Description", with: @item.description
    fill_in "Title", with: "Updated system test item"
    click_on "Update Item"

    assert_text "Item was successfully updated"
  end

  test "should destroy Item" do
    sign_in_as(users(:staff))
    @item = Item.create!(
      title: "Disposable system test item",
      description: "Created for deletion",
      category: :clothing,
      status: :available,
      date_found: Time.current,
      facility: users(:staff).facility
    )

    visit item_url(@item)
    click_button "Destroy this item"

    assert_text "Item was successfully destroyed"
  end
end
