FactoryBot.define do
  factory :sync_log do
    association :syncable, factory: :repository
    started_at { Time.current }
    finished_at { nil }
    status { 'running' }
    items_fetched { 0 }
    items_created { 0 }
    items_updated { 0 }
    error_message { nil }
    failed_items { [] }

    trait :for_github_project do
      association :syncable, factory: :github_project
    end

    trait :completed do
      status { 'completed' }
      finished_at { 5.minutes.from_now }
      items_fetched { 10 }
      items_created { 5 }
      items_updated { 3 }
    end

    trait :failed do
      status { 'failed' }
      finished_at { 5.minutes.from_now }
      error_message { 'API rate limit exceeded' }
    end
  end
end
