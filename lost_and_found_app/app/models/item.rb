class Item < ApplicationRecord
  belongs_to :facility
  has_many :claims, dependent: :destroy
  has_many :users, through: :claims

  enum :category, {clothing: 0, water_bottle: 1, electronic_device: 2, ID_card: 3, others: 4}
  enum :status, {available: 0, claim_pending: 1, claimed: 2}

  validates :title, presence: true
  validates :facility_id, presence: true
  validates :category, presence: true
  validates :status, presence: true
  #validate for custom-method
  validate :status_must_be_available_when_created, on: :create

  scope :search, ->(query) {
    if query.blank?
      all
    else
      where("title LIKE :query OR description LIKE :query", query: "%#{sanitize_sql_like(query)}%")
    end 
  }

  scope :by_facility, ->(id) {
    if id.present?
      where(facility_id: id)
    else
      all
    end
  }

  scope :by_category, ->(category) { 
    if category.present? 
      where(category: category)
    else 
      all
    end 
  }

  scope :by_status, ->(status) { 
    if status.present?
      where(status: status)
    else
      all 
    end
  }

  def submit_claim!
    raise "The item is not available" unless available?
    update!(status: :claim_pending)
  end

  def approve_claim!
    raise "The item is not under claim-pending" unless claim_pending?
    update!(status: :claimed)
  end

  def reject_claim!
    raise "The item is not under claim-pending" unless claim_pending?
    update!(status: :available)
  end

  private 

  def status_must_be_available_when_created
    errors.add(:status, "must be available when created") unless available?
  end

end
