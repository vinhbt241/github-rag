class CreateRepositories < ActiveRecord::Migration[8.1]
  def change
    create_table :repositories do |t|
      t.string :name, null: false
      t.string :full_name, null: false
      t.integer :github_id, null: false
      t.datetime :last_synced_at

      t.timestamps

      t.index :full_name, unique: true
      t.index :github_id, unique: true
    end
  end
end
