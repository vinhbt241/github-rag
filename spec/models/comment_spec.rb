require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:commentable_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:commentable_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:github_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:body).of_type(:text).with_options(null: false) }
    it { is_expected.to have_db_column(:author).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:comment_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:github_created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:github_updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index(:github_id).unique(true) }
    it { is_expected.to have_db_index([:commentable_type, :commentable_id]) }
  end

  describe 'factory' do
    it 'has a valid factory (default issue_comment)' do
      expect(build(:comment)).to be_valid
    end

    it 'has a valid :issue_comment trait' do
      expect(build(:comment, :issue_comment)).to be_valid
    end

    it 'has a valid :review_comment trait' do
      expect(build(:comment, :review_comment)).to be_valid
    end
  end

  describe 'validations' do
    subject { build(:comment) }

    it { is_expected.to validate_presence_of(:github_id) }
    it { is_expected.to validate_uniqueness_of(:github_id) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:comment_type) }
    it { is_expected.to validate_presence_of(:github_created_at) }
    it { is_expected.to validate_presence_of(:github_updated_at) }

    it { is_expected.to validate_presence_of(:commentable_type) }

    it 'validates inclusion of commentable_type in Issue and PullRequest' do
      comment = build(:comment, commentable_type: 'Repository')
      expect(comment).not_to be_valid
      expect(comment.errors[:commentable_type]).to include('is not included in the list')
    end

    it 'validates inclusion of comment_type in issue_comment and review_comment' do
      comment = build(:comment, comment_type: 'invalid')
      expect(comment).not_to be_valid
      expect(comment.errors[:comment_type]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:commentable) }

    it 'can belong to an Issue' do
      issue = create(:issue)
      comment = create(:comment, :issue_comment, commentable: issue)
      expect(comment.commentable).to eq(issue)
      expect(comment.commentable_type).to eq('Issue')
    end

    it 'can belong to a PullRequest' do
      pr = create(:pull_request)
      comment = create(:comment, :review_comment, commentable: pr)
      expect(comment.commentable).to eq(pr)
      expect(comment.commentable_type).to eq('PullRequest')
    end
  end

  describe 'edge cases' do
    it 'rejects duplicate github_id' do
      create(:comment, github_id: 12345)
      duplicate = build(:comment, github_id: 12345)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:github_id]).to include('has already been taken')
    end

    it 'rejects missing author' do
      comment = build(:comment, author: nil)
      expect(comment).not_to be_valid
    end

    it 'rejects blank body' do
      comment = build(:comment, body: '')
      expect(comment).not_to be_valid
    end

    it 'accepts long markdown body' do
      comment = build(:comment, body: '#' * 10_000)
      expect(comment).to be_valid
    end

    it 'accepts issue_comment type' do
      comment = build(:comment, comment_type: 'issue_comment')
      expect(comment).to be_valid
    end

    it 'accepts review_comment type' do
      comment = build(:comment, comment_type: 'review_comment')
      expect(comment).to be_valid
    end

    it 'rejects invalid comment_type' do
      comment = build(:comment, comment_type: 'pr_comment')
      expect(comment).not_to be_valid
    end

    it 'rejects comment without commentable' do
      comment = Comment.new(
        github_id: 1, body: 'test', author: 'test', url: 'https://example.com',
        comment_type: 'issue_comment', github_created_at: Time.current, github_updated_at: Time.current
      )
      expect(comment).not_to be_valid
    end

    it 'rejects comment without url' do
      comment = build(:comment, url: nil)
      expect(comment).not_to be_valid
    end

    it 'rejects comment without github_created_at' do
      comment = build(:comment, github_created_at: nil)
      expect(comment).not_to be_valid
    end

    it 'rejects comment without github_updated_at' do
      comment = build(:comment, github_updated_at: nil)
      expect(comment).not_to be_valid
    end

    it 'accepts Issue as commentable_type' do
      issue = create(:issue)
      comment = create(:comment, :issue_comment, commentable: issue, commentable_type: 'Issue')
      expect(comment).to be_valid
      expect(comment.commentable_type).to eq('Issue')
    end

    it 'accepts PullRequest as commentable_type' do
      pr = create(:pull_request)
      comment = create(:comment, :review_comment, commentable: pr, commentable_type: 'PullRequest')
      expect(comment).to be_valid
      expect(comment.commentable_type).to eq('PullRequest')
    end

    it 'rejects Repository as commentable_type' do
      repo = create(:repository)
      comment = Comment.new(
        commentable: repo,
        github_id: 999_999, body: 'test', author: 'test', url: 'https://example.com',
        comment_type: 'issue_comment', github_created_at: Time.current, github_updated_at: Time.current
      )
      expect(comment).not_to be_valid
      expect(comment.errors[:commentable_type]).to include('is not included in the list')
    end
  end
end
