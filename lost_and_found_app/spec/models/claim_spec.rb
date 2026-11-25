require "rails_helper"

RSpec.describe Claim, type: :model do
  it "cannot create claims with non-pending status" do
    claim1 = build(:claim, status: :approved)
    expect(claim1).not_to be_valid

    claim2 = build(:claim, status: :rejected)
    expect(claim2).not_to be_valid
  end

  it "rolls back claim if item transition fails" do
    facility = create(:facility)
    item = create(:item, facility: facility,status: :available)
    user = create(:user, :general)
    allow(item).to receive(:submit_claim!).and_raise("error")

    expect {
      ActiveRecord::Base.transaction do
        Claim.create!(item: item, user: user, facility: item.facility,
                      status: :pending, contact_info: "12345678")
        item.submit_claim!
      end
    }.to raise_error("error")

    expect(Claim.where(item: item).count).to eq(0)
    expect(item.reload).to be_available
  end
end