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

ActiveRecord::Schema.define(version: 20160315142010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artifacts", force: :cascade do |t|
    t.integer  "task_id"
    t.text     "name"
    t.text     "mimetype"
    t.binary   "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "execution_statuses", force: :cascade do |t|
    t.integer  "execution_id"
    t.text     "status"
    t.boolean  "current"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "execution_values", force: :cascade do |t|
    t.integer  "execution_id"
    t.integer  "value_id"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "executions", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seapig_router_session_states", force: :cascade do |t|
    t.integer  "seapig_router_session_id"
    t.integer  "state_id"
    t.jsonb    "state"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "seapig_router_session_states", ["seapig_router_session_id", "state_id"], name: "seapig_router_session_states_index_1", unique: true, using: :btree

  create_table "seapig_router_sessions", force: :cascade do |t|
    t.text     "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "seapig_router_sessions", ["key"], name: "index_seapig_router_sessions_on_key", unique: true, using: :btree

  create_table "task_statuses", force: :cascade do |t|
    t.integer  "task_id"
    t.text     "status"
    t.boolean  "current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_values", force: :cascade do |t|
    t.integer  "task_id"
    t.integer  "value_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "execution_id"
    t.jsonb    "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.text     "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "values", force: :cascade do |t|
    t.integer  "property_id"
    t.text     "value"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "worker_statuses", force: :cascade do |t|
    t.integer  "worker_id"
    t.boolean  "current"
    t.jsonb    "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workers", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
