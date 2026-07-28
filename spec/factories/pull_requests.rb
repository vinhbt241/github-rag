FactoryBot.define do
  factory :pull_request do
    association :repository
    sequence(:number) { |n| n }
    sequence(:github_id) { |n| 300_000 + n }
    title { Faker::Lorem.sentence(word_count: 5) }
    body { Faker::Lorem.paragraph }
    state { 'merged' }
    labels { [] }
    sequence(:url) { |n| "https://github.com/owner/repo/pull/#{n}" }
    merged_at { Faker::Time.backward(days: 30) }
    github_updated_at { Faker::Time.backward(days: 30) }
  end
end
