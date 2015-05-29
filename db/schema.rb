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

ActiveRecord::Schema.define(version: 20150511100215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actionkit_page_types", force: :cascade do |t|
    t.string "actionkit_page_type", null: false
  end

  create_table "actionkit_pages", force: :cascade do |t|
    t.integer "actionkit_id",             null: false
    t.integer "actionkit_page_type_id",   null: false
    t.integer "campaign_pages_widget_id", null: false
  end

  create_table "campaign_pages", force: :cascade do |t|
    t.integer  "language_id", null: false
    t.integer  "campaign_id"
    t.string   "title",       null: false
    t.string   "slug",        null: false
    t.boolean  "active",      null: false
    t.boolean  "featured",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_pages_widgets", force: :cascade do |t|
    t.jsonb   "content",            null: false
    t.integer "page_display_order", null: false
    t.integer "campaign_page_id",   null: false
    t.integer "widget_type_id",     null: false
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "campaign_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",        default: true
  end

  create_table "languages", force: :cascade do |t|
    t.string   "language_code", null: false
    t.string   "language_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: :cascade do |t|
    t.string "email_address",       null: false
    t.string "actionkit_member_id", null: false
  end

  create_table "templates", force: :cascade do |t|
    t.string  "template_name"
    t.boolean "active"
  end

  create_table "templates_widget_types", id: false, force: :cascade do |t|
    t.integer "template_id",    null: false
    t.integer "widget_type_id", null: false
    t.integer "page_order"
  end

  add_index "templates_widget_types", ["template_id"], name: "index_templates_widget_types_on_template_id", using: :btree
  add_index "templates_widget_types", ["widget_type_id"], name: "index_templates_widget_types_on_widget_type_id", using: :btree

  create_table "widget_types", force: :cascade do |t|
    t.string   "widget_name",       null: false
    t.jsonb    "specifications",    null: false
    t.string   "action_table_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",            null: false
  end

  add_foreign_key "actionkit_pages", "actionkit_page_types"
  add_foreign_key "actionkit_pages", "campaign_pages_widgets"
  add_foreign_key "campaign_pages", "campaigns"
  add_foreign_key "campaign_pages", "languages"
  add_foreign_key "campaign_pages_widgets", "campaign_pages"
  add_foreign_key "campaign_pages_widgets", "widget_types"
  add_foreign_key "templates_widget_types", "templates"
  add_foreign_key "templates_widget_types", "widget_types"
end
