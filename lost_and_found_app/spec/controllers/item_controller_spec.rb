require "rails_helper"

RSpec.describe ItemsController, type: :controller do
  fixtures :facilities, :users
  describe "Access limit on item" do
    it "assigns only available items for general users" do
      visible = create(:item, title: "Visible", status: :available)
      hidden = build(:item, title: "Hidden", status: :claim_pending)
      hidden.save!(validate: false)

      sign_in users(:user1)
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:items)).to include(visible)
      expect(assigns(:items)).not_to include(hidden)
    end

    it "filters by keyword for general users" do
      hoodie = create(:item, title: "Blue Hoodie", status: :available)
      usb = create(:item, title: "USB Drive", status: :available)

      sign_in users(:user1)
      get :index, params: { query: "Hoodie" }
      expect(response).to have_http_status(:ok)
      expect(assigns(:items)).to include(hoodie)
      expect(assigns(:items)).not_to include(usb)
    end

    it "assigns only items under same facility for staff" do
      lib = facilities(:library)
      sport = facilities(:sport_centre)
      item_a = create(:item, title: "A", facility: lib)
      item_b = create(:item, title: "B", facility: sport)

      sign_in users(:staff)
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:items)).to include(item_a)
      expect(assigns(:items)).not_to include(item_b)
    end
  end
end