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

ActiveRecord::Schema.define(version: 2021_08_12_102016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artifacts", id: :serial, force: :cascade do |t|
    t.integer "execution_id"
    t.integer "task_id"
    t.integer "size"
    t.text "mimetype"
    t.text "name"
    t.text "storage_handler"
    t.jsonb "storage_handler_data"
    t.text "external_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "hook_run_id"
    t.index ["created_at", "storage_handler", "id"], name: "artifacts_created_at_storage_handler_id_idx1"
    t.index ["execution_id"], name: "artifacts_execution_id_idx1", where: "(execution_id IS NOT NULL)"
    t.index ["hook_run_id"], name: "index_artifacts_on_hook_run_id", where: "(hook_run_id IS NOT NULL)"
    t.index ["task_id", "name"], name: "artifacts_task_id_name_idx1", where: "(task_id IS NOT NULL)"
  end

  create_table "broken_artifacts", id: false, force: :cascade do |t|
    t.integer "id"
    t.datetime "min"
    t.bigint "ct"
    t.index ["id", "min"], name: "broken_artifacts_id_min_idx"
  end

  create_table "broken_artifacts2", id: false, force: :cascade do |t|
    t.integer "id"
    t.datetime "min"
  end

  create_table "broken_artifacts3", id: false, force: :cascade do |t|
    t.integer "id"
    t.datetime "max"
    t.index ["id", "max"], name: "broken_artifacts3_id_max_idx"
  end

  create_table "execution_hooks", id: :serial, force: :cascade do |t|
    t.integer "execution_id"
    t.text "status"
    t.text "hook"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hook_run_id"
    t.index ["updated_at"], name: "execution_hooks_updated_at_idx"
  end

  create_table "execution_statuses", id: :serial, force: :cascade do |t|
    t.integer "execution_id"
    t.text "status"
    t.boolean "current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["execution_id"], name: "execution_statuses_execution_id_idx"
    t.index ["execution_id"], name: "execution_statuses_execution_id_idx1", where: "current"
  end

  create_table "execution_values", id: :serial, force: :cascade do |t|
    t.integer "execution_id"
    t.integer "value_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "property_id"
    t.index ["execution_id", "value_id"], name: "execution_values_execution_id_value_id_idx"
    t.index ["execution_id"], name: "execution_values_execution_id_idx"
    t.index ["value_id", "id"], name: "execution_values_value_id_id_idx"
    t.index ["value_id"], name: "execution_values_value_id_idx"
  end

  create_table "executions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "data"
    t.index ["user_id"], name: "executions_user_id_idx"
  end

  create_table "hook_runs", force: :cascade do |t|
    t.string "name"
    t.text "entity_type"
    t.text "entity_state"
    t.integer "execution_id"
    t.integer "task_id"
    t.text "arguments", default: [], array: true
    t.integer "exit_code"
    t.datetime "finished_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "properties", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requirements", id: :serial, force: :cascade do |t|
    t.uuid "uuid"
    t.jsonb "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "requirements_unique_uuid", unique: true
  end

  create_table "resource_statuses", id: :serial, force: :cascade do |t|
    t.integer "task_id"
    t.jsonb "description"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "current"
    t.text "role"
    t.index ["resource_id", "created_at"], name: "resource_statuses_resource_id_created_at_idx", where: "(task_id IS NULL)"
    t.index ["resource_id", "created_at"], name: "resource_statuses_resource_id_created_at_idx1", where: "(task_id IS NOT NULL)"
    t.index ["resource_id"], name: "resource_statuses_resource_id_idx", where: "current"
    t.index ["task_id"], name: "resource_statuses_task_id_idx"
  end

  create_table "resources", id: :serial, force: :cascade do |t|
    t.integer "worker_id"
    t.integer "remote_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resources_task_statuses", id: :serial, force: :cascade do |t|
    t.integer "resource_id"
    t.integer "task_status_id"
    t.index ["task_status_id", "resource_id"], name: "resources_task_statuses_task_status_id_resource_id_idx"
  end

  create_table "seapig_dependencies", id: :serial, force: :cascade do |t|
    t.text "name"
    t.bigint "current_version"
    t.bigint "reported_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "seapig_dependencies_id_idx", where: "(current_version <> reported_version)"
    t.index ["name", "current_version"], name: "seapig_dependencies_name_current_version_idx"
  end

  create_table "seapig_router_session_states", id: :serial, force: :cascade do |t|
    t.integer "seapig_router_session_id"
    t.integer "state_id"
    t.jsonb "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["seapig_router_session_id", "state_id"], name: "seapig_router_session_states_index_1", unique: true
  end

  create_table "seapig_router_sessions", id: :serial, force: :cascade do |t|
    t.text "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "token"
    t.index ["key", "token"], name: "seapig_router_sessions_key_token_index", unique: true
    t.index ["key"], name: "index_seapig_router_sessions_on_key", unique: true
    t.index ["token"], name: "seapig_router_sessions_token_index", unique: true
  end

  create_table "stats_counter", primary_key: ["status_table", "status_name"], force: :cascade do |t|
    t.string "status_table", null: false
    t.string "status_name", null: false
    t.integer "status_counter", null: false
  end

  create_table "task_hooks", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "hook"
    t.text "status"
    t.integer "execution_id"
    t.integer "task_id"
    t.integer "hook_run_id"
    t.index ["hook_run_id"], name: "index_task_hooks_on_hook_run_id", where: "(hook_run_id IS NOT NULL)"
  end

  create_table "task_statuses", id: :serial, force: :cascade do |t|
    t.integer "task_id"
    t.text "status"
    t.boolean "current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "worker_id"
    t.index ["status"], name: "task_statuses_status_idx", where: "(current = true)"
    t.index ["task_id"], name: "task_statuses_task_id_idx", where: "current"
    t.index ["task_id"], name: "task_statuses_task_id_idx1", where: "(current AND (status = 'waiting'::text))"
    t.index ["task_id"], name: "task_statuses_task_id_idx2", where: "(current AND (status = 'assigned'::text))"
    t.index ["worker_id", "created_at", "task_id"], name: "task_statuses_worker_id_created_at_task_id_idx", where: "(current AND (status = 'assigned'::text))"
    t.index ["worker_id", "task_id"], name: "task_statuses_worker_id_task_id_idx", where: "(current AND (status = 'accepted'::text))"
  end

  create_table "task_values", id: :serial, force: :cascade do |t|
    t.integer "task_id"
    t.integer "value_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "property_id"
    t.index ["task_id", "value_id"], name: "task_values_task_id_value_id_idx"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.integer "execution_id"
    t.jsonb "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "requirement_id", null: false
    t.integer "retry", limit: 2
    t.index ["execution_id"], name: "tasks_execution_id_idx"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.text "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "values", id: :serial, force: :cascade do |t|
    t.integer "property_id"
    t.text "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "property_id"], name: "values_id_property_id_idx"
    t.index ["property_id", "id"], name: "values_property_id_id_idx"
    t.index ["property_id"], name: "values_property_id_idx"
  end

  create_table "worker_statuses", id: :serial, force: :cascade do |t|
    t.integer "worker_id"
    t.boolean "current"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["worker_id"], name: "worker_statuses_worker_id_idx1", where: "current"
  end

  create_table "workers", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "id"], name: "workers_name_id_idx"
  end

end
