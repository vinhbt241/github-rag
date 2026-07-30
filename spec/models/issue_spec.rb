require 'rails_helper'

RSpec.describe Issue, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:github_project_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:number).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:github_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:body).of_type(:text).with_options(null: true) }
    it { is_expected.to have_db_column(:state).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:labels).of_type(:text).with_options(null: false) }
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:github_updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index([:github_project_id, :number]).unique(true) }
    it { is_expected.to have_db_index(:github_updated_at) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:issue)).to be_valid
    end
  end

  describe 'validations' do
    subject { create(:issue) }

    it { is_expected.to belong_to(:github_project) }
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:github_id) }
    it { is_expected.to validate_uniqueness_of(:github_id) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:github_updated_at) }

    it 'validates uniqueness of number scoped to github_project_id' do
      project = create(:github_project)
      create(:issue, github_project: project, number: 1)
      duplicate = build(:issue, github_project: project, number: 1, github_id: 999_999)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:number]).to include('has already been taken')
    end

    it 'validates inclusion of state in open and closed' do
      issue = build(:issue, state: 'invalid')
      expect(issue).not_to be_valid
      expect(issue.errors[:state]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:github_project) }
    it { is_expected.to have_many(:chunks).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe 'edge cases' do
    it 'rejects duplicate github_id' do
      create(:issue, github_id: 12345)
      duplicate = build(:issue, github_id: 12345)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:github_id]).to include('has already been taken')
    end

    it 'allows same number in different github_project_id' do
      project_a = create(:github_project)
      project_b = create(:github_project)
      create(:issue, github_project: project_a, number: 1, github_id: 111)
      other = build(:issue, github_project: project_b, number: 1, github_id: 222)
      expect(other).to be_valid
    end

    it 'rejects same number in same github_project_id' do
      project = create(:github_project)
      create(:issue, github_project: project, number: 1, github_id: 111)
      duplicate = build(:issue, github_project: project, number: 1, github_id: 222)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:number]).to include('has already been taken')
    end

    it 'allows body to be nil' do
      issue = build(:issue, body: nil)
      expect(issue).to be_valid
    end

    it 'defaults labels to empty array' do
      issue = build(:issue, labels: nil)
      # When labels is nil, it should still be valid due to NOT NULL + default
      # But we explicitly set it to nil here to test the edge case
      expect(issue).to be_valid
    end

    it 'rejects invalid state values' do
      issue = build(:issue, state: 'merged')
      expect(issue).not_to be_valid
    end

    it 'accepts open state' do
      issue = build(:issue, state: 'open')
      expect(issue).to be_valid
    end

    it 'accepts closed state' do
      issue = build(:issue, state: 'closed')
      expect(issue).to be_valid
    end

    it 'rejects issue without github_project_id' do
      issue = build(:issue, github_project: nil)
      expect(issue).not_to be_valid
    end

    it 'rejects issue without title' do
      issue = build(:issue, title: nil)
      expect(issue).not_to be_valid
    end

    it 'rejects issue without url' do
      issue = build(:issue, url: nil)
      expect(issue).not_to be_valid
    end

    it 'rejects issue without github_updated_at' do
      issue = build(:issue, github_updated_at: nil)
      expect(issue).not_to be_valid
    end
  end
end
