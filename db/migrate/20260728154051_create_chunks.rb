class CreateChunks < ActiveRecord::Migration[8.1]
  def up
    # Enable pgvector extension for vector similarity search
    enable_extension 'vector'

    create_table :chunks do |t|
      # Polymorphic parent (Issue or PullRequest)
      t.string :chunkable_type, null: false
      t.bigint :chunkable_id, null: false

      # Chunk metadata
      t.string :chunk_type, null: false          # "body" or "comment"
      t.integer :source_github_id                # GitHub comment ID (nil for body chunks)

      # Denormalized parent fields (for query convenience — avoids joins)
      t.string :title                            # Parent title
      t.string :parent_url, null: false          # Parent GitHub URL
      t.integer :parent_number, null: false      # Parent issue/PR number

      # Content
      t.text :content, null: false               # Raw chunk text
      t.text :embedding_text, null: false        # Text sent to embedding model

      # Access filtering (denormalized)
      t.string :repository                       # PR chunks: repo full_name
      t.string :project                          # Issue chunks: project title

      t.timestamps
    end

    # vector(1024) and tsvector require raw SQL (no pgvector gem)
    execute "ALTER TABLE chunks ADD COLUMN embedding vector(1024)"
    execute "ALTER TABLE chunks ADD COLUMN search_vector tsvector"

    # Lookup chunks by parent
    add_index :chunks, [:chunkable_type, :chunkable_id]

    # Prevent duplicate chunks for the same parent/comment on re-sync.
    # Note: source_github_id is NULL for body chunks. PostgreSQL treats NULLs as
    # distinct in unique indexes, so body-chunk dedup is handled at the app level.
    # Comment chunks (source_github_id IS NOT NULL) are fully protected here.
    add_index :chunks, [:chunkable_type, :chunkable_id, :chunk_type, :source_github_id],
              unique: true, name: 'index_chunks_on_parent_and_source'

    # Access filtering
    add_index :chunks, :repository
    add_index :chunks, :project

    # Full-text search (GIN index can be created immediately)
    execute "CREATE INDEX index_chunks_on_search_vector ON chunks USING GIN (search_vector)"

    # NOTE: ivfflat index on embedding should be added AFTER data is loaded.
    # ivfflat requires existing rows to build cluster centroids, and performs
    # best with at least 1000+ rows. Add it separately with:
    #
    #   CREATE INDEX index_chunks_on_embedding
    #   ON chunks USING ivfflat (embedding vector_cosine_ops)
    #   WITH (lists = 100);
    #
    # The `lists` parameter should be roughly sqrt(num_rows).
  end

  def down
    drop_table :chunks
    # Note: the pgvector extension is intentionally not dropped on rollback
    # as other tables or extensions may depend on it.
  end
end
