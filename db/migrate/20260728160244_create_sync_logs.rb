class CreateSyncLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_logs do |t|
      # Polymorphic parent (Repository or GithubProject)
      t.string :syncable_type, null: false
      t.bigint :syncable_id, null: false

      # Sync run tracking
      t.datetime :started_at, null: false
      t.datetime :finished_at            # Populated when sync completes
      t.string :status, null: false      # "running" / "completed" / "failed"
      t.integer :items_fetched, default: 0
      t.integer :items_created, default: 0
      t.integer :items_updated, default: 0
      t.text :error_message              # Populated when status = "failed"

      # No updated_at — sync logs are append-only records
      t.datetime :created_at, null: false
    end

    # Recent logs for a repo/project
    add_index :sync_logs, [:syncable_type, :syncable_id]
  end
end
