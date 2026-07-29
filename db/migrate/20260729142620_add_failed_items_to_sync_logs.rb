class AddFailedItemsToSyncLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :sync_logs, :failed_items, :jsonb, null: false, default: '[]'
  end
end
