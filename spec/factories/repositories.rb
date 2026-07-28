FactoryBot.define do
  factory :repository do
    sequence(:name) { |n| "repo-#{n}" }
    sequence(:full_name) { |n| "owner-#{n}/#{name}" }
    sequence(:github_id) { |n| 100_000 + n }
    last_synced_at { nil }
  end
end
