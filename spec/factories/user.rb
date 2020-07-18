FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "I am number #{n}" }
    balance { 100 }
  end
end
