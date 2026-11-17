class Facility < ApplicationRecord
  has_many :users
  has_many :items
  has_many :claims
end
