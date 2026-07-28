class Chunk < ApplicationRecord
  belongs_to :chunkable, polymorphic: true

  validates :chunkable_type, presence: true, inclusion: { in: %w[Issue PullRequest] }
  validates :chunk_type, presence: true, inclusion: { in: %w[body comment] }
  validates :parent_url, presence: true
  validates :parent_number, presence: true
  validates :content, presence: true
  validates :embedding_text, presence: true
end
