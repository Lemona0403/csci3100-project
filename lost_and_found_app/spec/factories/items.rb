FactoryBot.define do
  factory :item do
    sequence(:title) { |n| "Item #{n}" }
    description { "description" }
    category { :clothing }
    status { :available }
    date_found { Time.current }
    association :facility
    trait :claim_pending do
      status { :claim_pending }
    end
    trait :claimed do
      status { :claimed } 
    end 
  end
end