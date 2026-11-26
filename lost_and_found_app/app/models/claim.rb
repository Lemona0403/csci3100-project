class Claim < ApplicationRecord
  belongs_to :facility
  belongs_to :user
  belongs_to :item

  enum :status, {pending: 0, approved: 1, rejected: 2}

  validates :user_id, presence: true
  validates :item_id, presence: true
  validates :facility_id, presence: true
  validates :status, presence: true
  validate :status_must_be_pending_when_create, on: :create

  scope :search, ->(query) {
    if query.blank?
      all 
    else
      # LEFT OUTER JOIN items ON items.id = claims.item_id
      left_joins(:item).where(
        "items.title LIKE :query", query: "%#{sanitize_sql_like(query)}%"
      )
    end
  }

  scope :by_status, ->(status) {
    if status.present?
      where(status: status)
    else
      all
    end
  }

  def approve!
    raise "The claim has been approved or rejected" unless pending?
    update!(status: :approved)
  end

  def reject!
    raise "The claim has been approved or rejected" unless pending?
    update!(status: :rejected)
  end

  private

  def status_must_be_pending_when_create
    errors.add(:status, "must be pending when claim is created") unless pending?
  end

end
