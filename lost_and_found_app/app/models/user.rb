class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  belongs_to :facility, optional: true
  has_many :claims, dependent: :destroy
  has_many :items, through: :claims

  enum :role, {general: 0, staff: 1}
  #ensure staff have facility_id, general users have no facility_id
  validates :name, presence: true
  validates :facility_id, presence: true, if: :staff?
  validates :facility_id, absence: true, if: :general?
end
