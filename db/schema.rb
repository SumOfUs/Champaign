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

ActiveRecord::Schema.define(version: 20161229184851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actionkit_page_types", force: :cascade do |t|
    t.string "actionkit_page_type", null: false
  end

  create_table "actionkit_pages", force: :cascade do |t|
    t.integer "actionkit_id",           null: false
    t.integer "actionkit_page_type_id", null: false
  end

  create_table "actions", force: :cascade do |t|
    t.integer  "page_id"
    t.integer  "member_id"
    t.string   "link"
    t.boolean  "created_user"
    t.boolean  "subscribed_user"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.jsonb    "form_data",         default: {}
    t.boolean  "subscribed_member", default: true
    t.boolean  "donation",          default: false
  end

  add_index "actions", ["member_id"], name: "index_actions_on_member_id", using: :btree
  add_index "actions", ["page_id"], name: "index_actions_on_page_id", using: :btree

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "ak_logs", force: :cascade do |t|
    t.text     "request_body"
    t.text     "response_body"
    t.string   "response_status"
    t.string   "resource"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "calls", force: :cascade do |t|
    t.integer  "page_id"
    t.integer  "member_id"
    t.string   "member_phone_number"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donation_bands", force: :cascade do |t|
    t.string   "name"
    t.integer  "amounts",    default: [],              array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "form_elements", force: :cascade do |t|
    t.integer  "form_id"
    t.string   "label"
    t.string   "data_type"
    t.string   "default_value"
    t.boolean  "required"
    t.boolean  "visible"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "name"
    t.integer  "position",      default: 0,  null: false
    t.jsonb    "choices",       default: []
  end

  add_index "form_elements", ["form_id"], name: "index_form_elements_on_form_id", using: :btree

  create_table "forms", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "visible",       default: false
    t.boolean  "master",        default: false
    t.integer  "formable_id"
    t.string   "formable_type"
    t.integer  "position",      default: 0,     null: false
  end

  add_index "forms", ["formable_type", "formable_id"], name: "index_forms_on_formable_type_and_formable_id", using: :btree

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
    t.string   "code",          null: false
    t.string   "name",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actionkit_uri"
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
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.text     "description"
    t.boolean  "experimental",                default: false, null: false
    t.integer  "default_follow_up_layout_id"
    t.boolean  "primary_layout"
    t.boolean  "post_action_layout"
  end

  create_table "liquid_partials", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member_authentications", force: :cascade do |t|
    t.integer  "member_id"
    t.string   "password_digest",        null: false
    t.string   "facebook_uid"
    t.string   "facebook_token"
    t.datetime "facebook_token_expiry"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "token"
    t.datetime "confirmed_at"
    t.datetime "reset_password_sent_at"
    t.string   "reset_password_token"
  end

  add_index "member_authentications", ["facebook_uid"], name: "index_member_authentications_on_facebook_uid", using: :btree
  add_index "member_authentications", ["member_id"], name: "index_member_authentications_on_member_id", using: :btree
  add_index "member_authentications", ["reset_password_token"], name: "index_member_authentications_on_reset_password_token", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "email"
    t.string   "country"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "postal"
    t.string   "title"
    t.string   "address1"
    t.string   "address2"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "actionkit_user_id"
    t.integer  "donor_status",      default: 0, null: false
  end

  add_index "members", ["actionkit_user_id"], name: "index_members_on_actionkit_user_id", using: :btree
  add_index "members", ["email"], name: "index_members_on_email", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "language_id"
    t.integer  "campaign_id"
    t.string   "title",                                          null: false
    t.string   "slug",                                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "compiled_html"
    t.string   "status",                     default: "pending"
    t.text     "messages"
    t.text     "content",                    default: ""
    t.boolean  "featured",                   default: false
    t.integer  "liquid_layout_id"
    t.integer  "follow_up_liquid_layout_id"
    t.integer  "action_count",               default: 0
    t.integer  "primary_image_id"
    t.string   "ak_petition_resource_uri"
    t.string   "ak_donation_resource_uri"
    t.integer  "follow_up_plan",             default: 0,         null: false
    t.integer  "follow_up_page_id"
    t.text     "javascript"
    t.integer  "publish_status",             default: 1,         null: false
    t.integer  "optimizely_status",          default: 0,         null: false
    t.string   "canonical_url"
    t.boolean  "allow_duplicate_actions",    default: false
  end

  add_index "pages", ["campaign_id"], name: "index_pages_on_campaign_id", using: :btree
  add_index "pages", ["follow_up_liquid_layout_id"], name: "index_pages_on_follow_up_liquid_layout_id", using: :btree
  add_index "pages", ["follow_up_page_id"], name: "index_pages_on_follow_up_page_id", using: :btree
  add_index "pages", ["liquid_layout_id"], name: "index_pages_on_liquid_layout_id", using: :btree
  add_index "pages", ["primary_image_id"], name: "index_pages_on_primary_image_id", using: :btree
  add_index "pages", ["publish_status"], name: "index_pages_on_publish_status", using: :btree

  create_table "pages_tags", force: :cascade do |t|
    t.integer "page_id"
    t.integer "tag_id"
  end

  create_table "payment_braintree_customers", force: :cascade do |t|
    t.string   "card_type"
    t.string   "card_bin"
    t.string   "cardholder_name"
    t.string   "card_debit"
    t.string   "card_last_4"
    t.string   "card_vault_token"
    t.string   "card_unique_number_identifier"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "customer_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "member_id"
  end

  add_index "payment_braintree_customers", ["member_id"], name: "index_payment_braintree_customers_on_member_id", using: :btree

  create_table "payment_braintree_notifications", force: :cascade do |t|
    t.text     "payload"
    t.text     "signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_braintree_payment_methods", force: :cascade do |t|
    t.string   "token"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "customer_id"
    t.string   "card_type"
    t.string   "bin"
    t.string   "cardholder_name"
    t.string   "last_4"
    t.string   "expiration_date"
    t.string   "instrument_type"
    t.string   "email"
    t.boolean  "store_in_vault",  default: false
    t.datetime "cancelled_at"
  end

  add_index "payment_braintree_payment_methods", ["customer_id"], name: "braintree_customer_index", using: :btree
  add_index "payment_braintree_payment_methods", ["store_in_vault"], name: "index_payment_braintree_payment_methods_on_store_in_vault", using: :btree

  create_table "payment_braintree_subscriptions", force: :cascade do |t|
    t.string   "subscription_id"
    t.string   "merchant_account_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "page_id"
    t.decimal  "amount",               precision: 10, scale: 2
    t.string   "currency"
    t.integer  "action_id"
    t.datetime "cancelled_at"
    t.string   "customer_id"
    t.integer  "billing_day_of_month"
    t.integer  "payment_method_id"
  end

  add_index "payment_braintree_subscriptions", ["action_id"], name: "index_payment_braintree_subscriptions_on_action_id", using: :btree
  add_index "payment_braintree_subscriptions", ["page_id"], name: "index_payment_braintree_subscriptions_on_page_id", using: :btree
  add_index "payment_braintree_subscriptions", ["subscription_id"], name: "index_payment_braintree_subscriptions_on_subscription_id", using: :btree

  create_table "payment_braintree_transactions", force: :cascade do |t|
    t.string   "transaction_id"
    t.string   "transaction_type"
    t.datetime "transaction_created_at"
    t.string   "payment_method_token"
    t.string   "customer_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "merchant_account_id"
    t.string   "currency"
    t.integer  "page_id"
    t.string   "payment_instrument_type"
    t.integer  "status"
    t.decimal  "amount",                  precision: 10, scale: 2
    t.string   "processor_response_code"
    t.integer  "payment_method_id"
    t.integer  "subscription_id"
  end

  add_index "payment_braintree_transactions", ["page_id"], name: "index_payment_braintree_transactions_on_page_id", using: :btree
  add_index "payment_braintree_transactions", ["payment_method_id"], name: "braintree_payment_method_index", using: :btree
  add_index "payment_braintree_transactions", ["subscription_id"], name: "braintree_transaction_subscription", using: :btree

  create_table "payment_go_cardless_customers", force: :cascade do |t|
    t.string   "go_cardless_id"
    t.string   "email"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "postal_code"
    t.string   "country_code"
    t.string   "language"
    t.integer  "member_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "payment_go_cardless_customers", ["member_id"], name: "index_payment_go_cardless_customers_on_member_id", using: :btree

  create_table "payment_go_cardless_payment_methods", force: :cascade do |t|
    t.string   "go_cardless_id"
    t.string   "reference"
    t.string   "scheme"
    t.date     "next_possible_charge_date"
    t.integer  "customer_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "aasm_state"
    t.datetime "cancelled_at"
  end

  add_index "payment_go_cardless_payment_methods", ["customer_id"], name: "index_payment_go_cardless_payment_methods_on_customer_id", using: :btree

  create_table "payment_go_cardless_subscriptions", force: :cascade do |t|
    t.string   "go_cardless_id"
    t.decimal  "amount"
    t.string   "currency"
    t.integer  "status"
    t.string   "name"
    t.string   "payment_reference"
    t.integer  "page_id"
    t.integer  "action_id"
    t.integer  "payment_method_id"
    t.integer  "customer_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "aasm_state"
    t.datetime "cancelled_at"
  end

  add_index "payment_go_cardless_subscriptions", ["action_id"], name: "index_payment_go_cardless_subscriptions_on_action_id", using: :btree
  add_index "payment_go_cardless_subscriptions", ["customer_id"], name: "index_payment_go_cardless_subscriptions_on_customer_id", using: :btree
  add_index "payment_go_cardless_subscriptions", ["page_id"], name: "index_payment_go_cardless_subscriptions_on_page_id", using: :btree
  add_index "payment_go_cardless_subscriptions", ["payment_method_id"], name: "index_payment_go_cardless_subscriptions_on_payment_method_id", using: :btree

  create_table "payment_go_cardless_transactions", force: :cascade do |t|
    t.string   "go_cardless_id"
    t.date     "charge_date"
    t.decimal  "amount"
    t.string   "description"
    t.string   "currency"
    t.integer  "status"
    t.string   "reference"
    t.decimal  "amount_refunded"
    t.integer  "page_id"
    t.integer  "payment_method_id"
    t.integer  "customer_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "aasm_state"
    t.integer  "subscription_id"
  end

  add_index "payment_go_cardless_transactions", ["customer_id"], name: "index_payment_go_cardless_transactions_on_customer_id", using: :btree
  add_index "payment_go_cardless_transactions", ["page_id"], name: "index_payment_go_cardless_transactions_on_page_id", using: :btree
  add_index "payment_go_cardless_transactions", ["payment_method_id"], name: "index_payment_go_cardless_transactions_on_payment_method_id", using: :btree
  add_index "payment_go_cardless_transactions", ["subscription_id"], name: "go_cardless_transaction_subscription", using: :btree

  create_table "payment_go_cardless_webhook_events", force: :cascade do |t|
    t.string   "event_id"
    t.string   "resource_type"
    t.string   "action"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "resource_id"
  end

  add_index "payment_go_cardless_webhook_events", ["event_id"], name: "index_payment_go_cardless_webhook_events_on_event_id", using: :btree

  create_table "plugins_call_tools", force: :cascade do |t|
    t.integer  "page_id"
    t.boolean  "active"
    t.string   "ref"
    t.integer  "form_id"
    t.json     "targets"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plugins_fundraisers", force: :cascade do |t|
    t.string   "title"
    t.string   "ref"
    t.integer  "page_id"
    t.boolean  "active",            default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "form_id"
    t.integer  "donation_band_id"
    t.integer  "recurring_default", default: 0,     null: false
  end

  add_index "plugins_fundraisers", ["donation_band_id"], name: "index_plugins_fundraisers_on_donation_band_id", using: :btree
  add_index "plugins_fundraisers", ["form_id"], name: "index_plugins_fundraisers_on_form_id", using: :btree
  add_index "plugins_fundraisers", ["page_id"], name: "index_plugins_fundraisers_on_page_id", using: :btree

  create_table "plugins_petitions", force: :cascade do |t|
    t.integer  "page_id"
    t.boolean  "active",      default: false
    t.integer  "form_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "description"
    t.string   "ref"
    t.string   "target"
    t.string   "cta"
  end

  add_index "plugins_petitions", ["form_id"], name: "index_plugins_petitions_on_form_id", using: :btree
  add_index "plugins_petitions", ["page_id"], name: "index_plugins_petitions_on_page_id", using: :btree

  create_table "plugins_surveys", force: :cascade do |t|
    t.integer  "page_id"
    t.boolean  "active",     default: false
    t.string   "ref"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plugins_surveys", ["page_id"], name: "index_plugins_surveys_on_page_id", using: :btree

  create_table "plugins_texts", force: :cascade do |t|
    t.text     "content"
    t.string   "ref"
    t.integer  "page_id"
    t.boolean  "active",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plugins_texts", ["page_id"], name: "index_plugins_texts_on_page_id", using: :btree

  create_table "plugins_thermometers", force: :cascade do |t|
    t.string   "title"
    t.integer  "offset"
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
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "page_id"
    t.integer  "share_count"
    t.integer  "click_count"
    t.string   "sp_id"
    t.integer  "image_id"
  end

  add_index "share_facebooks", ["button_id"], name: "index_share_facebooks_on_button_id", using: :btree
  add_index "share_facebooks", ["image_id"], name: "index_share_facebooks_on_image_id", using: :btree
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

  create_table "uris", force: :cascade do |t|
    t.string   "domain"
    t.string   "path"
    t.integer  "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "uris", ["page_id"], name: "index_uris_on_page_id", using: :btree

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
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "actionkit_pages", "actionkit_page_types"
  add_foreign_key "actions", "members"
  add_foreign_key "actions", "pages"
  add_foreign_key "form_elements", "forms"
  add_foreign_key "links", "pages"
  add_foreign_key "member_authentications", "members"
  add_foreign_key "pages", "campaigns"
  add_foreign_key "pages", "images", column: "primary_image_id"
  add_foreign_key "pages", "languages"
  add_foreign_key "pages", "liquid_layouts"
  add_foreign_key "pages", "liquid_layouts", column: "follow_up_liquid_layout_id"
  add_foreign_key "payment_braintree_customers", "members"
  add_foreign_key "payment_braintree_subscriptions", "pages"
  add_foreign_key "payment_braintree_transactions", "pages"
  add_foreign_key "payment_go_cardless_customers", "members"
  add_foreign_key "payment_go_cardless_payment_methods", "payment_go_cardless_customers", column: "customer_id"
  add_foreign_key "payment_go_cardless_subscriptions", "actions"
  add_foreign_key "payment_go_cardless_subscriptions", "pages"
  add_foreign_key "payment_go_cardless_subscriptions", "payment_go_cardless_customers", column: "customer_id"
  add_foreign_key "payment_go_cardless_subscriptions", "payment_go_cardless_payment_methods", column: "payment_method_id"
  add_foreign_key "payment_go_cardless_transactions", "pages"
  add_foreign_key "payment_go_cardless_transactions", "payment_go_cardless_customers", column: "customer_id"
  add_foreign_key "payment_go_cardless_transactions", "payment_go_cardless_payment_methods", column: "payment_method_id"
  add_foreign_key "plugins_fundraisers", "donation_bands"
  add_foreign_key "plugins_fundraisers", "forms"
  add_foreign_key "plugins_fundraisers", "pages"
  add_foreign_key "plugins_petitions", "forms"
  add_foreign_key "plugins_petitions", "pages"
  add_foreign_key "plugins_thermometers", "pages"
  add_foreign_key "share_emails", "pages"
  add_foreign_key "share_facebooks", "images"
  add_foreign_key "share_twitters", "pages"
  add_foreign_key "uris", "pages"
end
