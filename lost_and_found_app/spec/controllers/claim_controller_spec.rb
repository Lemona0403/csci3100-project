require "rails_helper"

RSpec.describe ClaimsController, type: :controller do
  fixtures :users
  describe "Access limit of claim" do
    it "cannot see other users' claims" do
      item = create(:item, status: :available)
      item.update_column(:status, Item.statuses[:claim_pending])
      user1_claim = create(:claim, item: item, user: users(:user1), facility: item.facility)

      sign_in users(:user2)
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:claims)).not_to include(user1_claim)
      expect(assigns(:claims)).to be_empty
    end
  end

  describe "Create claims" do
    it "calls submit_claim! on the item" do
      item = create(:item, status: :available)
      sign_in users(:user1)

      allow(Item).to receive(:find).and_return(item)
      expect(item).to receive(:submit_claim!)

      post :create, params: {
        item_id: item.id,
        claim: { contact_info: "1", message: "x" }
      }
    end

    it "creates pending claim and sets item to claim_pending" do
      item = create(:item, status: :available)
      sign_in users(:user1)

      expect {
        post :create, params: {
          item_id: item.id,
          claim: { contact_info: "1", message: "x" }
        }
      }.to change(Claim, :count).by(1)

      expect(Claim.last).to be_pending
      expect(item.reload).to be_claim_pending
      expect(response).to redirect_to(claim_path(Claim.last))
    end

    it "blocks claiming non-available items" do
      item = create(:item, status: :available)
      item.submit_claim!
      sign_in users(:user1)

      expect {
        post :create, params: {
          item_id: item.id,
          claim: { contact_info: "1", message: "x" }
        }
      }.not_to change(Claim, :count)

      expect(response).to redirect_to(item_path(item))
                      .or have_http_status(:unprocessable_content)
    end
  end

  describe "Staff changes status of claim" do
    it "sets claim to approved & item to claimed when staff approve" do
      staff = users(:staff)
      item = build(:item, status: :claim_pending, facility: staff.facility)
      item.save!(validate: false)
      claim = create(:claim, item: item, user: users(:user1),facility: item.facility, 
      status: :pending)
      sign_in users(:staff)

      patch :update, params: { id: claim.id, claim: { status: "approved" } }
      expect(claim.reload).to be_approved
      expect(item.reload).to be_claimed
      expect(response).to redirect_to(claim_path(claim))
    end

    it "sets claim to rejected & item to available when staff reject" do
      staff = users(:staff)
      item = build(:item, status: :claim_pending, facility: staff.facility)
      item.save!(validate: false)
      claim = create(:claim, item: item, user: users(:user1), facility: item.facility,
      status: :pending)
      sign_in staff

      patch :update, params: { id: claim.id, claim: { status: "rejected" } }
      expect(claim.reload).to be_rejected
      expect(item.reload).to be_available
      expect(response).to redirect_to(claim_path(claim))
    end
  end
end