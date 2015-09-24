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

ActiveRecord::Schema.define(version: 20150924201854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_users", force: :cascade do |t|
    t.string   "email"
    t.string   "country"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "postal_code"
    t.string   "title"
    t.string   "address1"
    t.string   "address2"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "actionkit_page_types", force: :cascade do |t|
    t.string "actionkit_page_type", null: false
  end

  create_table "actionkit_pages", force: :cascade do |t|
    t.integer "actionkit_id",           null: false
    t.integer "actionkit_page_type_id", null: false
  end

  create_table "actions", force: :cascade do |t|
    t.integer  "page_id"
    t.integer  "action_user_id"
    t.string   "link"
    t.boolean  "created_user"
    t.boolean  "subscribed_user"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.jsonb    "form_data"
  end

  add_index "actions", ["action_user_id"], name: "index_actions_on_action_user_id", using: :btree
  add_index "actions", ["page_id"], name: "index_actions_on_page_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     default: true
  end

  create_table "form_elements", force: :cascade do |t|
    t.integer  "form_id"
    t.string   "label"
    t.string   "data_type"
    t.string   "field_type"
    t.string   "default_value"
    t.boolean  "required"
    t.boolean  "visible"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "name"
    t.integer  "position",      default: 0, null: false
  end

  add_index "form_elements", ["form_id"], name: "index_form_elements_on_form_id", using: :btree

  create_table "forms", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "visible",     default: false
    t.boolean  "master",      default: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "content_file_name"
    t.string   "content_content_type"
    t.integer  "content_file_size"
    t.datetime "content_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
  end

  add_index "images", ["page_id"], name: "index_images_on_page_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "code",       null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.string   "date"
    t.string   "source"
    t.integer  "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "links", ["page_id"], name: "index_links_on_page_id", using: :btree

  create_table "liquid_layouts", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "liquid_partials", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.string "email_address",       null: false
    t.string "actionkit_member_id", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.integer  "language_id"
    t.integer  "campaign_id"
    t.string   "title",                                null: false
    t.string   "slug",                                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "compiled_html"
    t.text     "content",          default: ""
    t.boolean  "thermometer",      default: false
    t.boolean  "featured",         default: false
    t.boolean  "active",           default: false
    t.string   "status",           default: "pending"
    t.text     "messages"
    t.integer  "liquid_layout_id"
  end

  add_index "pages", ["liquid_layout_id"], name: "index_pages_on_liquid_layout_id", using: :btree

  create_table "pages_tags", force: :cascade do |t|
    t.integer "page_id"
    t.integer "tag_id"
  end

  create_table "plugins_actions", force: :cascade do |t|
    t.integer  "page_id"
    t.boolean  "active",      default: false
    t.integer  "form_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "description"
    t.string   "ref"
    t.string   "target"
  end

  add_index "plugins_actions", ["form_id"], name: "index_plugins_actions_on_form_id", using: :btree
  add_index "plugins_actions", ["page_id"], name: "index_plugins_actions_on_page_id", using: :btree

  create_table "plugins_thermometers", force: :cascade do |t|
    t.string   "title"
    t.integer  "offset"
    t.integer  "goal"
    t.integer  "page_id"
    t.boolean  "active",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "ref"
  end

  add_index "plugins_thermometers", ["page_id"], name: "index_plugins_thermometers_on_page_id", using: :btree

  create_table "share_buttons", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "sp_id"
    t.integer  "page_id"
    t.string   "sp_type"
    t.string   "sp_button_html"
    t.text     "analytics"
  end

  add_index "share_buttons", ["page_id"], name: "index_share_buttons_on_page_id", using: :btree

  create_table "share_emails", force: :cascade do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "page_id"
    t.string   "sp_id"
    t.integer  "button_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "share_emails", ["page_id"], name: "index_share_emails_on_page_id", using: :btree

  create_table "share_facebooks", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "image"
    t.integer  "button_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "page_id"
    t.integer  "share_count"
    t.integer  "click_count"
    t.string   "sp_id"
  end

  add_index "share_facebooks", ["button_id"], name: "index_share_facebooks_on_button_id", using: :btree
  add_index "share_facebooks", ["page_id"], name: "index_share_facebooks_on_page_id", using: :btree

  create_table "share_twitters", force: :cascade do |t|
    t.integer  "sp_id"
    t.integer  "page_id"
    t.string   "title"
    t.string   "description"
    t.integer  "button_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "share_twitters", ["page_id"], name: "index_share_twitters_on_page_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.string   "actionkit_uri"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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

  add_foreign_key "actionkit_pages", "actionkit_page_types"
  add_foreign_key "actions", "action_users"
  add_foreign_key "actions", "pages"
  add_foreign_key "form_elements", "forms"
  add_foreign_key "links", "pages"
  add_foreign_key "pages", "campaigns"
  add_foreign_key "pages", "languages"
  add_foreign_key "pages", "liquid_layouts"
  add_foreign_key "plugins_actions", "forms"
  add_foreign_key "plugins_actions", "pages"
  add_foreign_key "plugins_thermometers", "pages"
  add_foreign_key "share_emails", "pages"
  add_foreign_key "share_twitters", "pages"
end
