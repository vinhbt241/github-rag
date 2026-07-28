require 'rails_helper'

RSpec.describe Repository, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:full_name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:github_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:last_synced_at).of_type(:datetime).with_options(null: true) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index(:full_name).unique(true) }
    it { is_expected.to have_db_index(:github_id).unique(true) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:repository)).to be_valid
    end
  end

  describe 'validations' do
    subject { create(:repository) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_uniqueness_of(:full_name) }
    it { is_expected.to validate_presence_of(:github_id) }
    it { is_expected.to validate_uniqueness_of(:github_id) }
  end

  describe 'edge cases' do
    it 'rejects duplicate full_name' do
      create(:repository, full_name: 'acme/gateway')
      duplicate = build(:repository, full_name: 'acme/gateway')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:full_name]).to include('has already been taken')
    end

    it 'rejects duplicate github_id' do
      create(:repository, github_id: 12345)
      duplicate = build(:repository, github_id: 12345)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:github_id]).to include('has already been taken')
    end

    it 'allows last_synced_at to be nil' do
      repo = build(:repository, last_synced_at: nil)
      expect(repo).to be_valid
    end

    it 'rejects repository without name' do
      repo = build(:repository, name: nil)
      expect(repo).not_to be_valid
    end

    it 'rejects repository without full_name' do
      repo = build(:repository, full_name: nil)
      expect(repo).not_to be_valid
    end

    it 'rejects repository without github_id' do
      repo = build(:repository, github_id: nil)
      expect(repo).not_to be_valid
    end
  end
end
