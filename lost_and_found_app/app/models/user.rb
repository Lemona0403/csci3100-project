class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :lockable

  belongs_to :facility, optional: true
  has_many :claims, dependent: :destroy
  has_many :items, through: :claims

  enum :role, {general: 0, staff: 1}
  #ensure staff have facility_id, general users have no facility_id
  validates :name, presence: true
  validates :facility_id, presence: true, if: :staff?
  validates :facility_id, absence: true, if: :general?
  validate :password_has_three_character_types, if: -> { password.present? }

  def unauthenticated_message
    message = super
    return message unless message == :locked && locked_at

    remaining_seconds = (self.class.unlock_in - (Time.current - locked_at)).ceil
    return message unless remaining_seconds.positive?

    minutes, seconds = remaining_seconds.divmod(60)
    I18n.t("devise.failure.locked_with_time", minutes:, seconds:)
  end

  private

  def password_has_three_character_types
    character_types = [
      password.match?(/[A-Z]/),
      password.match?(/[a-z]/),
      password.match?(/[0-9]/),
      password.match?(/[^A-Za-z0-9\s]/)
    ]

    return if character_types.count(true) >= 3

    errors.add(:password, "must include at least three of uppercase letters, lowercase letters, numbers, and symbols")
  end
end
