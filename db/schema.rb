# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_28_152317) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "github_projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "github_node_id", null: false
    t.datetime "last_synced_at"
    t.integer "number", null: false
    t.string "owner", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["github_node_id"], name: "index_github_projects_on_github_node_id", unique: true
  end

  create_table "issues", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "github_id", null: false
    t.bigint "github_project_id", null: false
    t.datetime "github_updated_at", null: false
    t.text "labels", default: [], null: false, array: true
    t.integer "number", null: false
    t.string "state", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["github_id"], name: "index_issues_on_github_id", unique: true
    t.index ["github_project_id", "number"], name: "index_issues_on_github_project_id_and_number", unique: true
    t.index ["github_project_id"], name: "index_issues_on_github_project_id"
    t.index ["github_updated_at"], name: "index_issues_on_github_updated_at"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "github_id", null: false
    t.datetime "github_updated_at", null: false
    t.text "labels", default: [], null: false, array: true
    t.datetime "merged_at"
    t.integer "number", null: false
    t.bigint "repository_id", null: false
    t.string "state", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["github_id"], name: "index_pull_requests_on_github_id", unique: true
    t.index ["github_updated_at"], name: "index_pull_requests_on_github_updated_at"
    t.index ["repository_id", "number"], name: "index_pull_requests_on_repository_id_and_number", unique: true
    t.index ["repository_id"], name: "index_pull_requests_on_repository_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "full_name", null: false
    t.integer "github_id", null: false
    t.datetime "last_synced_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_repositories_on_full_name", unique: true
    t.index ["github_id"], name: "index_repositories_on_github_id", unique: true
  end

  add_foreign_key "issues", "github_projects"
  add_foreign_key "pull_requests", "repositories"
end
