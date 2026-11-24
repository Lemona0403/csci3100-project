FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "User" }
    password { "ABCabc123!@#" }
    trait :general do
      role { :general }
      facility_id { nil }
    end 
    trait :staff do
      role { :staff }
      association :facility
    end
  end
end