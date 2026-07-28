require 'rails_helper'

RSpec.describe SyncLog, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:syncable_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:syncable_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:started_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:finished_at).of_type(:datetime).with_options(null: true) }
    it { is_expected.to have_db_column(:status).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:items_fetched).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:items_created).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:items_updated).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:error_message).of_type(:text).with_options(null: true) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.not_to have_db_column(:updated_at) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index([:syncable_type, :syncable_id]) }
  end

  describe 'factory' do
    it 'has a valid factory (default running for repository)' do
      expect(create(:sync_log)).to be_valid
    end

    it 'has a valid :for_github_project trait' do
      expect(create(:sync_log, :for_github_project)).to be_valid
    end

    it 'has a valid :completed trait' do
      expect(create(:sync_log, :completed)).to be_valid
    end

    it 'has a valid :failed trait' do
      expect(create(:sync_log, :failed)).to be_valid
    end
  end

  describe 'validations' do
    subject { create(:sync_log) }

    it { is_expected.to validate_presence_of(:syncable_type) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:started_at) }

    it 'validates inclusion of syncable_type in Repository and GithubProject' do
      log = build(:sync_log)
      log.syncable_type = 'Issue'
      expect(log).not_to be_valid
      expect(log.errors[:syncable_type]).to include('is not included in the list')
    end

    it 'validates inclusion of status in running, completed, and failed' do
      log = build(:sync_log, status: 'invalid')
      expect(log).not_to be_valid
      expect(log.errors[:status]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:syncable) }

    it 'can belong to a Repository' do
      repo = create(:repository)
      log = create(:sync_log, syncable: repo)
      expect(log.syncable).to eq(repo)
      expect(log.syncable_type).to eq('Repository')
    end

    it 'can belong to a GithubProject' do
      project = create(:github_project)
      log = create(:sync_log, :for_github_project, syncable: project)
      expect(log.syncable).to eq(project)
      expect(log.syncable_type).to eq('GithubProject')
    end
  end

  describe 'polymorphic behavior' do
    it 'tracks sync for a repository' do
      repo = create(:repository)
      log = create(:sync_log, :completed, syncable: repo, items_fetched: 15, items_created: 8)
      expect(log.syncable).to eq(repo)
      expect(log.items_fetched).to eq(15)
      expect(log.items_created).to eq(8)
    end

    it 'tracks sync for a github project' do
      project = create(:github_project)
      log = create(:sync_log, :for_github_project, :completed, syncable: project)
      expect(log.syncable).to eq(project)
    end
  end

  describe 'nullable fields' do
    it 'allows finished_at to be nil (running sync)' do
      log = create(:sync_log, finished_at: nil)
      expect(log).to be_valid
    end

    it 'allows error_message to be nil (non-failed sync)' do
      log = create(:sync_log, :completed, error_message: nil)
      expect(log).to be_valid
    end
  end

  describe 'edge cases' do
    it 'rejects syncable_type with blank string' do
      log = build(:sync_log)
      log.syncable_type = ''
      expect(log).not_to be_valid
      expect(log.errors[:syncable_type]).to be_present
    end

    it 'rejects invalid status' do
      log = build(:sync_log, status: 'cancelled')
      expect(log).not_to be_valid
      expect(log.errors[:status]).to include('is not included in the list')
    end

    it 'rejects log without syncable parent' do
      log = build(:sync_log, syncable: nil)
      expect(log).not_to be_valid
    end

    it 'rejects log without started_at' do
      log = build(:sync_log, started_at: nil)
      expect(log).not_to be_valid
    end

    it 'accepts running status' do
      log = build(:sync_log, status: 'running')
      expect(log).to be_valid
    end

    it 'accepts completed status' do
      log = build(:sync_log, :completed)
      expect(log).to be_valid
    end

    it 'accepts failed status with error message' do
      log = build(:sync_log, :failed)
      expect(log).to be_valid
    end

    it 'defaults counter columns to 0' do
      log = create(:sync_log)
      expect(log.items_fetched).to eq(0)
      expect(log.items_created).to eq(0)
      expect(log.items_updated).to eq(0)
    end
  end
end
