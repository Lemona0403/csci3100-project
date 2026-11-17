class User < ApplicationRecord
  belongs_to :facility, optional: true
  has_many :claims, dependent: :destroy
  has_many :items, through: :claims

  enum :role, {general: 0, staff: 1}
  #ensure staff have facility_id, general users have no facility_id
  validates :facility_id, presence: true, if: :staff?
  validates :facility_id, absence: true, if: :general?

  validates :email, presence: true
  validates :password, presence: true
  validates :name, presence: true
  validates :role, presence: true


end
