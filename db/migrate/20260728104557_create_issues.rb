class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues do |t|
      t.references :github_project, null: false, foreign_key: true
      t.integer :number, null: false
      t.integer :github_id, null: false
      t.string :title, null: false
      t.text :body
      t.string :state, null: false
      t.text :labels, array: true, null: false, default: []
      t.string :url, null: false
      t.datetime :github_updated_at, null: false

      t.timestamps

      t.index [:github_project_id, :number], unique: true
      t.index :github_updated_at
      t.index :github_id, unique: true
    end
  end
end
