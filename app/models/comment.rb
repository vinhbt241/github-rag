class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true

  validates :github_id, presence: true, uniqueness: true
  validates :body, presence: true
  validates :author, presence: true
  validates :url, presence: true
  validates :comment_type, presence: true, inclusion: { in: %w[issue_comment review_comment] }
  validates :github_created_at, presence: true
  validates :github_updated_at, presence: true

  COMMENT_TYPES = %w[issue_comment review_comment].freeze
end
