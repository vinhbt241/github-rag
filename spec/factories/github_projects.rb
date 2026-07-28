FactoryBot.define do
  factory :github_project do
    title { Faker::App.name }
    sequence(:number) { |n| n }
    sequence(:owner) { |n| "org-#{n}" }
    sequence(:github_node_id) { |n| "PN_kwDOAA#{n.to_s.rjust(6, '0')}" }
    last_synced_at { nil }
  end
end
