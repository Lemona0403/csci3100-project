require "rails_helper"

RSpec.describe Item, type: :model do
  it "cannot create item with non-available status" do
    item1 = build(:item, status: :claimed)
    expect(item1).not_to be_valid
    expect(item1.errors[:status]).to be_present

    item2 = build(:item, status: :claim_pending)
    expect(item2).not_to be_valid
    expect(item2.errors[:status]).to be_present
  end

  it "turns item from available to claim_pending when claim is created" do
    item = create(:item, status: :available)
    item.submit_claim!
    expect(item.reload).to be_claim_pending
  end

  it "rejects submit_claim! when item is claim_pending" do
    item = create(:item, status: :available)
    item.submit_claim!
    expect { item.submit_claim! }.to raise_error(/not available/)
    expect(item.reload).to be_claim_pending
  end
end