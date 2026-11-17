class Claim < ApplicationRecord
  belongs_to :facility
  belongs_to :user
  belongs_to :item

  enum :status, {pending: 0, approved: 1, rejected: 2}

  validates :user_id, presence: true
  validates :item_id, presence: true
  validates :facility_id, presence: true
  validates :status, presence: true

  def approve!
    raise "The claim has been approved or rejected" unless pending?
    update(status: :approved)
  end

  def reject!
    raise "The claim has been approved or rejected" unless pending?
    update(status: :rejected)
  end
end
