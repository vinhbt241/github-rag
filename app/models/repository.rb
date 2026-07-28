class Repository < ApplicationRecord
  has_many :sync_logs, as: :syncable, dependent: :destroy

  validates :name, presence: true
  validates :full_name, presence: true, uniqueness: true
  validates :github_id, presence: true, uniqueness: true
end
