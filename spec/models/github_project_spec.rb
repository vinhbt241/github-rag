require 'rails_helper'

RSpec.describe GithubProject, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:number).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:owner).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:github_node_id).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:last_synced_at).of_type(:datetime).with_options(null: true) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index(:github_node_id).unique(true) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:github_project)).to be_valid
    end
  end

  describe 'validations' do
    subject { create(:github_project) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_presence_of(:github_node_id) }
    it { is_expected.to validate_uniqueness_of(:github_node_id) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:issues).dependent(:destroy) }
    it { is_expected.to have_many(:sync_logs).dependent(:destroy) }
  end

  describe 'edge cases' do
    it 'rejects duplicate github_node_id' do
      create(:github_project, github_node_id: 'PN_kwDOAA000001')
      duplicate = build(:github_project, github_node_id: 'PN_kwDOAA000001')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:github_node_id]).to include('has already been taken')
    end

    it 'allows same number for different owners' do
      create(:github_project, number: 1, owner: 'org-a', github_node_id: 'PN_AAA')
      other = build(:github_project, number: 1, owner: 'org-b', github_node_id: 'PN_BBB')
      expect(other).to be_valid
    end

    it 'allows last_synced_at to be nil' do
      project = build(:github_project, last_synced_at: nil)
      expect(project).to be_valid
    end

    it 'rejects project without title' do
      project = build(:github_project, title: nil)
      expect(project).not_to be_valid
    end

    it 'rejects project without number' do
      project = build(:github_project, number: nil)
      expect(project).not_to be_valid
    end

    it 'rejects project without owner' do
      project = build(:github_project, owner: nil)
      expect(project).not_to be_valid
    end

    it 'rejects project without github_node_id' do
      project = build(:github_project, github_node_id: nil)
      expect(project).not_to be_valid
    end
  end
end
