FactoryBot.define do
  factory :comment do
    association :commentable, factory: :issue
    sequence(:github_id) { |n| 400_000 + n }
    body { Faker::Lorem.paragraph(sentence_count: 3) }
    author { Faker::Internet.username(specifier: nil, separators: ['']) }
    url { "https://github.com/owner/repo/issues/#{commentable.number}/comments/#{github_id}" }
    comment_type { :issue_comment }
    github_created_at { Faker::Time.backward(days: 30) }
    github_updated_at { Faker::Time.backward(days: 15) }

    trait :issue_comment do
      association :commentable, factory: :issue
      comment_type { :issue_comment }
    end

    trait :review_comment do
      association :commentable, factory: :pull_request
      comment_type { :review_comment }
      url { "https://github.com/owner/repo/pull/#{commentable.number}/reviews/#{github_id}" }
    end
  end
end
