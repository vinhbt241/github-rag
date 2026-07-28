FactoryBot.define do
  factory :chunk do
    association :chunkable, factory: :pull_request
    chunk_type { 'body' }
    source_github_id { nil }
    title { Faker::Lorem.sentence(word_count: 4) }
    parent_url { Faker::Internet.url(host: 'github.com', path: '/owner/repo/pull/1') }
    parent_number { 1 }
    content { Faker::Lorem.paragraph(sentence_count: 3) }
    embedding_text { Faker::Lorem.paragraph(sentence_count: 5) }
    embedding { nil }
    search_vector { nil }
    repository { 'owner/repo' }
    project { nil }

    trait :for_issue do
      association :chunkable, factory: :issue
      repository { nil }
      project { Faker::App.name }
      parent_url { Faker::Internet.url(host: 'github.com', path: '/org/project/issues/1') }
    end

    trait :comment do
      chunk_type { 'comment' }
      source_github_id { Faker::Number.unique.number(digits: 8) }
    end
  end
end
