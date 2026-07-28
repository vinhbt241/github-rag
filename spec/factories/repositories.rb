FactoryBot.define do
  factory :repository do
    name { Faker::App.name.downcase.gsub(/\s+/, '-') }
    full_name { "#{Faker::Internet.username(specifier: 5..10)}/#{name}" }
    github_id { Faker::Number.unique.number(digits: 8) }
    last_synced_at { nil }
  end
end
