class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, null: false
      t.integer :github_id, null: false
      t.text :body, null: false
      t.string :author, null: false
      t.string :url, null: false
      t.string :comment_type, null: false
      t.datetime :github_created_at, null: false
      t.datetime :github_updated_at, null: false

      t.timestamps
    end

    add_index :comments, :github_id, unique: true
    add_index :comments, [:commentable_type, :commentable_id]
  end
end
