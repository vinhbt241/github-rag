class CreatePullRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :pull_requests do |t|
      t.references :repository, null: false, foreign_key: true
      t.integer :number, null: false
      t.integer :github_id, null: false
      t.string :title, null: false
      t.text :body
      t.string :state, null: false
      t.text :labels, array: true, null: false, default: []
      t.string :url, null: false
      t.datetime :merged_at
      t.datetime :github_updated_at, null: false

      t.timestamps

      t.index [:repository_id, :number], unique: true
      t.index :github_updated_at
      t.index :github_id, unique: true
    end
  end
end
