class CreateGithubProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :github_projects do |t|
      t.string :title, null: false
      t.integer :number, null: false
      t.string :owner, null: false
      t.string :github_node_id, null: false
      t.datetime :last_synced_at

      t.timestamps

      t.index :github_node_id, unique: true
    end
  end
end
