class Item < ApplicationRecord
  belongs_to :facility
  has_many :claims, dependent: :destroy
  has_many :users, through: :claims
  has_one_attached :photo

  enum :category, {clothing: 0, water_bottle: 1, electronic_device: 2, ID_card: 3, others: 4}
  enum :status, {available: 0, claim_pending: 1, claimed: 2}

  validates :title, presence: true
  validates :facility_id, presence: true
  validates :category, presence: true
  validates :status, presence: true
  #validate for custom-method
  validate :status_must_be_available_when_created, on: :create
  validate :valid_photo

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
    make_available_after_claim!
  end

  def cancel_claim!
    make_available_after_claim!
  end

  private 

  def make_available_after_claim!
    raise "The item is not under claim-pending" unless claim_pending?
    update!(status: :available)
  end

  def status_must_be_available_when_created
    errors.add(:status, "must be available when created") unless available?
  end

  def valid_photo
    return unless photo.attached?
    errors.add(:photo, "must be a JPEG/PNG/WebP") unless 
    photo.content_type.in?(%w[image/jpeg image/png image/webp])
    errors.add(:photo, "is too large") if photo.byte_size > 5.megabytes
  end

end
