class GithubProject < ApplicationRecord
  has_many :issues, dependent: :destroy

  validates :title, :number, :owner, :github_node_id, presence: true
  validates :github_node_id, uniqueness: true
end
