require 'rails_helper'

RSpec.describe PullRequest, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:repository_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:number).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:github_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:body).of_type(:text).with_options(null: true) }
    it { is_expected.to have_db_column(:state).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:labels).of_type(:text).with_options(null: false) }
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:merged_at).of_type(:datetime).with_options(null: true) }
    it { is_expected.to have_db_column(:github_updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index([:repository_id, :number]).unique(true) }
    it { is_expected.to have_db_index(:github_updated_at) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:pull_request)).to be_valid
    end
  end

  describe 'validations' do
    subject { create(:pull_request) }

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:github_id) }
    it { is_expected.to validate_uniqueness_of(:github_id) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:github_updated_at) }

    it 'validates uniqueness of number scoped to repository_id' do
      repo = create(:repository)
      create(:pull_request, repository: repo, number: 1)
      duplicate = build(:pull_request, repository: repo, number: 1, github_id: 999_999)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:number]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:repository) }
  end

  describe 'edge cases' do
    it 'rejects duplicate github_id' do
      create(:pull_request, github_id: 12345)
      duplicate = build(:pull_request, github_id: 12345)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:github_id]).to include('has already been taken')
    end

    it 'allows same number in different repository_id' do
      repo_a = create(:repository)
      repo_b = create(:repository)
      create(:pull_request, repository: repo_a, number: 1, github_id: 111)
      other = build(:pull_request, repository: repo_b, number: 1, github_id: 222)
      expect(other).to be_valid
    end

    it 'rejects same number in same repository_id' do
      repo = create(:repository)
      create(:pull_request, repository: repo, number: 1, github_id: 111)
      duplicate = build(:pull_request, repository: repo, number: 1, github_id: 222)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:number]).to include('has already been taken')
    end

    it 'allows body to be nil' do
      pr = build(:pull_request, body: nil)
      expect(pr).to be_valid
    end

    it 'allows merged_at to be nil' do
      pr = build(:pull_request, merged_at: nil)
      expect(pr).to be_valid
    end

    it 'defaults labels to empty array' do
      pr = build(:pull_request, labels: nil)
      expect(pr).to be_valid
    end

    it 'accepts array of label strings' do
      pr = build(:pull_request, labels: ['bug', 'enhancement', 'v2.0'])
      expect(pr).to be_valid
    end

    it 'rejects pull request without repository' do
      pr = build(:pull_request, repository: nil)
      expect(pr).not_to be_valid
    end

    it 'rejects pull request without title' do
      pr = build(:pull_request, title: nil)
      expect(pr).not_to be_valid
    end

    it 'rejects pull request without url' do
      pr = build(:pull_request, url: nil)
      expect(pr).not_to be_valid
    end

    it 'rejects pull request without github_updated_at' do
      pr = build(:pull_request, github_updated_at: nil)
      expect(pr).not_to be_valid
    end

    it 'rejects pull request without number' do
      pr = build(:pull_request, number: nil)
      expect(pr).not_to be_valid
    end

    it 'rejects pull request without state' do
      pr = build(:pull_request, state: nil)
      expect(pr).not_to be_valid
    end
  end
end
