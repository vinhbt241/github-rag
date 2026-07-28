FactoryBot.define do
  factory :issue do
    association :github_project
    sequence(:number) { |n| n }
    sequence(:github_id) { |n| 200_000 + n }
    title { Faker::Lorem.sentence(word_count: 5) }
    body { Faker::Lorem.paragraph }
    state { %w[open closed].sample }
    labels { [] }
    sequence(:url) { |n| "https://github.com/owner/project/issues/#{n}" }
    github_updated_at { Faker::Time.backward(days: 30) }
  end
end
