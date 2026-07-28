require 'rails_helper'

RSpec.describe Chunk, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:chunkable_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:chunkable_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:chunk_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:source_github_id).of_type(:integer).with_options(null: true) }
    it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_column(:parent_url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:parent_number).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:content).of_type(:text).with_options(null: false) }
    it { is_expected.to have_db_column(:embedding_text).of_type(:text).with_options(null: false) }
    it { is_expected.to have_db_column(:repository).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_column(:project).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it 'has the embedding column of type vector(1024)' do
      result = ActiveRecord::Base.connection.execute(
        "SELECT udt_name FROM information_schema.columns WHERE table_name = 'chunks' AND column_name = 'embedding'"
      )
      expect(result.first['udt_name']).to eq('vector')
    end

    it 'has the search_vector column of type tsvector' do
      result = ActiveRecord::Base.connection.execute(
        "SELECT data_type FROM information_schema.columns WHERE table_name = 'chunks' AND column_name = 'search_vector'"
      )
      expect(result.first['data_type']).to eq('tsvector')
    end
  end

  describe 'indexes' do
    it { is_expected.to have_db_index([:chunkable_type, :chunkable_id]) }
    it { is_expected.to have_db_index([:chunkable_type, :chunkable_id, :chunk_type, :source_github_id]).unique(true) }
    it { is_expected.to have_db_index(:repository) }
    it { is_expected.to have_db_index(:project) }

    it 'has a GIN index on search_vector' do
      result = ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT indexname FROM pg_indexes
        WHERE tablename = 'chunks' AND indexdef LIKE '%USING gin%search_vector%'
      SQL
      expect(result.count).to eq(1)
    end
  end

  describe 'factory' do
    it 'has a valid factory (default PR body chunk)' do
      expect(create(:chunk)).to be_valid
    end

    it 'has a valid :for_issue trait' do
      expect(create(:chunk, :for_issue)).to be_valid
    end

    it 'has a valid :comment trait' do
      expect(create(:chunk, :comment)).to be_valid
    end
  end

  describe 'validations' do
    subject { create(:chunk) }

    it { is_expected.to validate_presence_of(:chunkable_type) }
    it { is_expected.to validate_presence_of(:chunk_type) }
    it { is_expected.to validate_presence_of(:parent_url) }
    it { is_expected.to validate_presence_of(:parent_number) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:embedding_text) }

    it 'validates inclusion of chunkable_type in Issue and PullRequest' do
      chunk = build(:chunk, chunkable_type: '')
      expect(chunk).not_to be_valid
      expect(chunk.errors[:chunkable_type]).to be_present
    end

    it 'validates inclusion of chunk_type in body and comment' do
      chunk = build(:chunk, chunk_type: 'attachment')
      expect(chunk).not_to be_valid
      expect(chunk.errors[:chunk_type]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:chunkable) }

    it 'can belong to an Issue' do
      issue = create(:issue)
      chunk = create(:chunk, :for_issue, chunkable: issue)
      expect(chunk.chunkable).to eq(issue)
    end

    it 'can belong to a PullRequest' do
      pr = create(:pull_request)
      chunk = create(:chunk, chunkable: pr)
      expect(chunk.chunkable).to eq(pr)
    end
  end

  describe 'polymorphic behavior' do
    it 'stores repository but not project for PR chunks' do
      pr = create(:pull_request)
      chunk = create(:chunk, chunkable: pr, repository: 'owner/repo', project: nil)
      expect(chunk.repository).to eq('owner/repo')
      expect(chunk.project).to be_nil
    end

    it 'stores project but not repository for issue chunks' do
      issue = create(:issue)
      chunk = create(:chunk, :for_issue, chunkable: issue, project: 'My Project', repository: nil)
      expect(chunk.project).to eq('My Project')
      expect(chunk.repository).to be_nil
    end
  end

  describe 'nullable fields' do
    it 'allows source_github_id to be nil (body chunks)' do
      chunk = create(:chunk, source_github_id: nil)
      expect(chunk).to be_valid
    end

    it 'allows title to be nil' do
      chunk = create(:chunk, title: nil)
      expect(chunk).to be_valid
    end

    it 'allows embedding to be nil (before embedding generation)' do
      chunk = create(:chunk, embedding: nil)
      expect(chunk).to be_valid
    end

    it 'allows search_vector to be nil' do
      chunk = create(:chunk, search_vector: nil)
      expect(chunk).to be_valid
    end

    it 'allows repository to be nil (issue chunks)' do
      chunk = create(:chunk, :for_issue, repository: nil)
      expect(chunk).to be_valid
    end

    it 'allows project to be nil (PR chunks)' do
      chunk = create(:chunk, project: nil)
      expect(chunk).to be_valid
    end
  end

  describe 'edge cases' do
    it 'rejects invalid chunkable_type' do
      chunk = build(:chunk)
      chunk.chunkable_type = ''
      expect(chunk).not_to be_valid
      expect(chunk.errors[:chunkable_type]).to be_present
    end

    it 'rejects invalid chunk_type' do
      chunk = build(:chunk, chunk_type: 'attachment')
      expect(chunk).not_to be_valid
      expect(chunk.errors[:chunk_type]).to include('is not included in the list')
    end

    it 'rejects chunk without content' do
      chunk = build(:chunk, content: '')
      expect(chunk).not_to be_valid
    end

    it 'rejects chunk without embedding_text' do
      chunk = build(:chunk, embedding_text: '')
      expect(chunk).not_to be_valid
    end

    it 'rejects chunk without parent_url' do
      chunk = build(:chunk, parent_url: '')
      expect(chunk).not_to be_valid
    end

    it 'rejects chunk without parent_number' do
      chunk = build(:chunk, parent_number: nil)
      expect(chunk).not_to be_valid
    end

    it 'rejects chunk without a chunkable parent' do
      chunk = build(:chunk, chunkable: nil)
      expect(chunk).not_to be_valid
    end

    it 'rejects duplicate comment chunks for the same parent' do
      pr = create(:pull_request)
      create(:chunk, :comment, chunkable: pr, source_github_id: 12345)
      duplicate = build(:chunk, :comment, chunkable: pr, source_github_id: 12345)
      expect { duplicate.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows multiple body chunks for the same parent (NULL source_github_id)' do
      pr = create(:pull_request)
      create(:chunk, chunkable: pr, source_github_id: nil)
      second = build(:chunk, chunkable: pr, source_github_id: nil)
      # PostgreSQL treats NULLs as distinct in unique indexes
      expect { second.save! }.not_to raise_error
    end
  end
end
