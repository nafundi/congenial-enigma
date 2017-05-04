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

ActiveRecord::Schema.define(version: 20170430194855) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.text     "rule_type",               null: false
    t.jsonb    "rule_data",  default: {}, null: false
    t.text     "email",                   null: false
    t.text     "message",                 null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "configured_services", force: :cascade do |t|
    t.text     "type",                    null: false
    t.text     "name",                    null: false
    t.jsonb    "settings",   default: {}, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "data_source_alerts", force: :cascade do |t|
    t.integer  "data_source_id", null: false
    t.integer  "alert_id",       null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["alert_id"], name: "index_data_source_alerts_on_alert_id", using: :btree
    t.index ["data_source_id"], name: "index_data_source_alerts_on_data_source_id", using: :btree
  end

  create_table "data_sources", force: :cascade do |t|
    t.text     "name",                               null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "type",                               null: false
    t.jsonb    "settings",              default: {}, null: false
    t.integer  "configured_service_id",              null: false
  end

end
