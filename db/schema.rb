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

ActiveRecord::Schema.define(version: 20150731143047) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actionkit_page_types", force: :cascade do |t|
    t.string "actionkit_page_type", null: false
  end

  create_table "actionkit_pages", force: :cascade do |t|
    t.integer "actionkit_id",           null: false
    t.integer "actionkit_page_type_id", null: false
    t.integer "widget_id",              null: false
  end

  create_table "campaign_pages", force: :cascade do |t|
    t.integer  "language_id",                       null: false
    t.integer  "campaign_id"
    t.string   "title",                             null: false
    t.string   "slug",                              null: false
    t.boolean  "active",                            null: false
    t.boolean  "featured",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "compiled_html"
    t.string   "status",        default: "pending"
    t.text     "messages"
  end

  create_table "campaign_pages_tags", force: :cascade do |t|
    t.integer "campaign_page_id"
    t.integer "tag_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "campaign_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",        default: true
  end

  create_table "images", force: :cascade do |t|
    t.string   "content_file_name"
    t.string   "content_content_type"
    t.integer  "content_file_size"
    t.datetime "content_updated_at"
    t.integer  "widget_id"
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

  create_table "tags", force: :cascade do |t|
    t.string   "tag_name"
    t.string   "actionkit_uri"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "templates", force: :cascade do |t|
    t.string  "template_name"
    t.boolean "active"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "widgets", force: :cascade do |t|
    t.jsonb    "content"
    t.string   "type"
    t.integer  "page_display_order"
    t.integer  "page_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "page_type"
  end

  add_index "widgets", ["page_id"], name: "index_widgets_on_page_id", using: :btree

  add_foreign_key "actionkit_pages", "actionkit_page_types"
  add_foreign_key "campaign_pages", "campaigns"
  add_foreign_key "campaign_pages", "languages"
end
