class Comment < ApplicationRecord
  COMMENT_TYPES = %w[issue_comment review_comment].freeze

  belongs_to :commentable, polymorphic: true

  validates :commentable_type, presence: true, inclusion: { in: %w[Issue PullRequest] }
  validates :github_id, presence: true, uniqueness: true
  validates :body, presence: true
  validates :author, presence: true
  validates :url, presence: true
  validates :comment_type, presence: true, inclusion: { in: COMMENT_TYPES }
  validates :github_created_at, presence: true
  validates :github_updated_at, presence: true
end
