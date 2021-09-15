# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160826112501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artifacts", force: :cascade do |t|
    t.integer  "task_id"
    t.text     "name"
    t.text     "mimetype"
    t.binary   "data"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "execution_id"
  end

  add_index "artifacts", ["execution_id"], name: "artifacts_execution_id_idx", where: "(execution_id IS NOT NULL)", using: :btree
  add_index "artifacts", ["task_id", "name"], name: "artifacts_task_id_name_idx", using: :btree
  add_index "artifacts", ["task_id"], name: "artifacts_task_id_idx", where: "(execution_id IS NOT NULL)", using: :btree
  add_index "artifacts", ["updated_at"], name: "artifacts_updated_at_idx", using: :btree

  create_table "execution_hooks", force: :cascade do |t|
    t.integer  "execution_id"
    t.text     "status"
    t.text     "hook"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "execution_hooks", ["updated_at"], name: "execution_hooks_updated_at_idx", using: :btree

  create_table "execution_statuses", force: :cascade do |t|
    t.integer  "execution_id"
    t.text     "status"
    t.boolean  "current"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "execution_statuses", ["execution_id"], name: "execution_statuses_execution_id_idx", using: :btree
  add_index "execution_statuses", ["execution_id"], name: "execution_statuses_execution_id_idx1", where: "current", using: :btree
  add_index "execution_statuses", ["updated_at"], name: "execution_statuses_updated_at_idx", using: :btree

  create_table "execution_values", force: :cascade do |t|
    t.integer  "execution_id"
    t.integer  "value_id"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "execution_values", ["execution_id", "value_id"], name: "execution_values_execution_id_value_id_idx", using: :btree
  add_index "execution_values", ["execution_id"], name: "execution_values_execution_id_idx", using: :btree
  add_index "execution_values", ["updated_at"], name: "execution_values_updated_at_idx", using: :btree
  add_index "execution_values", ["value_id"], name: "execution_values_value_id_idx", using: :btree

  create_table "executions", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb    "data"
  end

  add_index "executions", ["updated_at"], name: "executions_updated_at_idx", using: :btree
  add_index "executions", ["user_id"], name: "executions_user_id_idx", using: :btree

  create_table "properties", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "properties", ["updated_at"], name: "properties_updated_at_idx", using: :btree

  create_table "resource_statuses", force: :cascade do |t|
    t.integer  "task_id"
    t.jsonb    "description"
    t.integer  "resource_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "current"
  end

  add_index "resource_statuses", ["resource_id", "created_at"], name: "resource_statuses_resource_id_created_at_idx", where: "(task_id IS NULL)", using: :btree
  add_index "resource_statuses", ["resource_id"], name: "resource_statuses_resource_id_idx", where: "current", using: :btree
  add_index "resource_statuses", ["task_id"], name: "resource_statuses_task_id_idx", using: :btree

  create_table "resources", force: :cascade do |t|
    t.integer  "worker_id"
    t.integer  "remote_id"
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "resources", ["updated_at"], name: "resources_updated_at_idx", using: :btree

  create_table "seapig_dependencies", force: :cascade do |t|
    t.text     "name"
    t.integer  "current_version",  limit: 8
    t.integer  "reported_version", limit: 8
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "seapig_dependencies", ["name", "current_version"], name: "seapig_dependencies_name_current_version_idx", using: :btree

  create_table "seapig_router_session_states", force: :cascade do |t|
    t.integer  "seapig_router_session_id"
    t.integer  "state_id"
    t.jsonb    "state"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "seapig_router_session_states", ["seapig_router_session_id", "state_id"], name: "seapig_router_session_states_index_1", unique: true, using: :btree
  add_index "seapig_router_session_states", ["updated_at"], name: "seapig_router_session_states_updated_at_idx", using: :btree

  create_table "seapig_router_sessions", force: :cascade do |t|
    t.text     "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "seapig_router_sessions", ["key"], name: "index_seapig_router_sessions_on_key", unique: true, using: :btree
  add_index "seapig_router_sessions", ["updated_at"], name: "seapig_router_sessions_updated_at_idx", using: :btree

  create_table "task_statuses", force: :cascade do |t|
    t.integer  "task_id"
    t.text     "status"
    t.boolean  "current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "worker_id"
  end

  add_index "task_statuses", ["task_id"], name: "task_statuses_task_id_idx", where: "current", using: :btree
  add_index "task_statuses", ["task_id"], name: "task_statuses_task_id_idx1", where: "(current AND (status = 'waiting'::text))", using: :btree
  add_index "task_statuses", ["updated_at"], name: "task_statuses_updated_at_idx", using: :btree

  create_table "task_values", force: :cascade do |t|
    t.integer  "task_id"
    t.integer  "value_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "task_values", ["task_id", "value_id"], name: "task_values_task_id_value_id_idx", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.integer  "execution_id"
    t.jsonb    "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "tasks", ["execution_id"], name: "tasks_execution_id_idx", using: :btree
  add_index "tasks", ["updated_at"], name: "tasks_updated_at_idx", using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["updated_at"], name: "users_updated_at_idx", using: :btree

  create_table "values", force: :cascade do |t|
    t.integer  "property_id"
    t.text     "value"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "values", ["property_id"], name: "values_property_id_idx", using: :btree
  add_index "values", ["updated_at"], name: "values_updated_at_idx", using: :btree

  create_table "worker_statuses", force: :cascade do |t|
    t.integer  "worker_id"
    t.boolean  "current"
    t.jsonb    "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "worker_statuses", ["worker_id"], name: "worker_statuses_worker_id_idx1", where: "current", using: :btree

  create_table "workers", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "workers", ["updated_at"], name: "workers_updated_at_idx", using: :btree

end
