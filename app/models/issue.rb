class Issue < ApplicationRecord
  belongs_to :github_project
  has_many :chunks, as: :chunkable, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :github_project_id }
  validates :github_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :state, presence: true, inclusion: { in: %w[open closed] }
  validates :url, presence: true
  validates :github_updated_at, presence: true
end
