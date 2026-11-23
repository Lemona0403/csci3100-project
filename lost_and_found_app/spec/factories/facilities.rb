FactoryBot.define do
  factory :facility do
    sequence(:name) { |n| "Facility #{n}" }
    location { "Campus" }
  end
end