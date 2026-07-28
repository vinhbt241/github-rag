class SyncLog < ApplicationRecord
  belongs_to :syncable, polymorphic: true

  validates :syncable_type, presence: true, inclusion: { in: %w[Repository GithubProject] }
  validates :status, presence: true, inclusion: { in: %w[running completed failed] }
  validates :started_at, presence: true
end
