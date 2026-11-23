FactoryBot.define do
  factory :claim do
    association :user, factory: [:user, :general]
    association :item
    facility { item.facility }
    status { :pending }
    contact_info { "12345678" }
  end
end