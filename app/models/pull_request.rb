class PullRequest < ApplicationRecord
  belongs_to :repository
  has_many :chunks, as: :chunkable, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :repository_id }
  validates :github_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :state, presence: true
  validates :url, presence: true
  validates :github_updated_at, presence: true
end
