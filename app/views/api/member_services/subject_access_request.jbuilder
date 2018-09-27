# frozen_string_literal: true
# json.(@data[:member], :id, :email, :country, :first_name, :last_name, :city, :postal, :title, :address1, :address2, :created_at, :updated_at, :actionkit_user_id, :donor_status, :more, :consented_updated_at, :consented)
# json.(@data[:member])
# json.member json.(@data[:member], :id, :email, :country, :first_name, :last_name, :city, :postal, :title, :address1, :address2, :created_at, :updated_at, :actionkit_user_id, :donor_status, :more, :consented_updated_at, :consented)
@data.keys.each do |key|
  json.set! key.to_sym, @data[key]
end
# json.member @data[:member]
# json.actions @data[:actions]
# json.calls @data[:calls]
# json.authentications @data[:authentications]
# json.go_cardless_subscriptions @data[:go_cardless_subscriptions]
# json.go_cardless_transactions @data[:go_cardless_transactions]
# json.go_cardless_payment_methods @data[:go_cardless_payment_methods]
# json.braintree_customer @data[:braintree_customer]
#
# json.set! :go_cardless_payment_methods do
#   @data[:go_cardless_payment_methods].each do |payment_method|
#     json(payment_method, :id, :go_cardless_id, :reference, :scheme, :next_possible_charge_date, :customer_id, :created_at, :updated_at, :aasm_state, :cancelled_at)
#   end
# end
# :braintree_customer,
# :braintree_subscriptions,
# :braintree_payment_methods,
# :braintree_transactions,
# :go_cardless_customers,
#
# {"id"=>3,
#  "go_cardless_id"=>"CU000492XKXPMH",
#  "email"=>nil,
#  "given_name"=>nil,
#  "family_name"=>nil,
#  "postal_code"=>nil,
#  "country_code"=>nil,
#  "language"=>nil,
#  "member_id"=>1,
#  "created_at"=>Thu, 20 Sep 2018 11:01:18 UTC +00:00,
#     "updated_at"=>Thu, 20 Sep 2018 11:01:18 UTC +00:00}
#
# # :go_cardless_payment_methods,
#
# {"id"=>3,
#  "go_cardless_id"=>"MD000453NJSHJB",
#  "reference"=>nil,
#  "scheme"=>"bacs",
#  "next_possible_charge_date"=>Wed, 26 Sep 2018,
#     "customer_id"=>3,
#     "created_at"=>Thu, 20 Sep 2018 11:01:18 UTC +00:00,
#     "updated_at"=>Thu, 20 Sep 2018 11:01:18 UTC +00:00,
#     "aasm_state"=>"pending",
#     "cancelled_at"=>nil}
#
# # :go_cardless_transactions,
#
# {"id"=>2,
#  "go_cardless_id"=>"PM000BXZKWAH86",
#  "charge_date"=>Mon, 22 Oct 2018,
#   "amount"=>0.713e1,
#   "description"=>nil,
#   "currency"=>"GBP",
#   "status"=>nil,
#   "reference"=>nil,
#   "amount_refunded"=>nil,
#   "page_id"=>6,
#   "payment_method_id"=>3,
#   "customer_id"=>3,
#   "created_at"=>Thu, 20 Sep 2018 11:01:18 UTC +00:00,
#   "updated_at"=>Thu, 20 Sep 2018 11:01:18 UTC +00:00,
#   "aasm_state"=>"created",
#   "subscription_id"=>nil}
#
#
# # :go_cardless_subscriptions
#
# [{"id"=>1,
#   "go_cardless_id"=>"SB0000J0QE64Q0",
#   "amount"=>0.1e2,
#   "currency"=>"GBP",
#   "status"=>nil,
#   "name"=>nil,
#   "payment_reference"=>nil,
#   "page_id"=>6,
#   "action_id"=>37,
#   "payment_method_id"=>2,
#   "customer_id"=>2,
#   "created_at"=>Thu, 20 Sep 2018 10:48:19 UTC +00:00,
#     "updated_at"=>Thu, 20 Sep 2018 10:48:19 UTC +00:00,
#     "aasm_state"=>"pending",
#     "cancelled_at"=>nil}]
#
#
# # Authentication
# {"id"=>1,
#  "member_id"=>1,
#  "facebook_uid"=>nil,
#  "facebook_token"=>nil,
#  "facebook_token_expiry"=>nil,
#  "created_at"=>Fri, 14 Sep 2018 07:46:45 UTC +00:00,
#     "updated_at"=>Fri, 14 Sep 2018 07:46:45 UTC +00:00,
#     "token"=>"diDq1K3L2AyvIGa26k6hJGDUC0KNXa2O",
#     "confirmed_at"=>nil,
# "reset_password_sent_at"=>nil,
# "reset_password_token"=>nil}
#
#
# # Call
#
# # Action
# [{"id"=>32505585,
#   "page_id"=>3325,
#   "member_id"=>10480267,
#   "link"=>nil,
#   "created_user"=>nil,
#   "subscribed_user"=>nil,
#   "created_at"=>Thu, 13 Sep 2018 08:27:28 UTC +00:00,
#     "updated_at"=>Thu, 13 Sep 2018 08:27:28 UTC +00:00,
#     "form_data"=>
#     {"name"=>"Tuuli",
#      "email"=>"tuuli@sumofus.org",
#      "postal"=>"1000",
#      "country"=>"SI",
#      "form_id"=>"6045",
#      "page_id"=>"3325",
#      "consented"=>true,
#      "action_mobile"=>"desktop",
#      "action_referer"=>
#          "https://actions.sumofus.org/pages/show-your-support-for-nationalising-britain-s-water-industry",
#      "action_phone_number"=>""},
#     "subscribed_member"=>false,
# "donation"=>false,
# "publish_status"=>"default",
#     :page_slug=>
#     "show-your-support-for-nationalising-britain-s-water-industry"},
#
#
# # Member
# {"id"=>10480267,
#  "email"=>"tuuli@sumofus.org",
#  "country"=>"SI",
#  "first_name"=>"Tuuli",
#  "last_name"=>"",
#  "city"=>"San Francisco",
#  "postal"=>"1000",
#  "title"=>nil,
#  "address1"=>nil,
#  "address2"=>nil,
#  "created_at"=>Mon, 21 Mar 2016 13:14:25 UTC +00:00,
#  "updated_at"=>Thu, 13 Sep 2018 08:27:28 UTC +00:00,
#  "actionkit_user_id"=>"8244194",
#  "donor_status"=>"recurring_donor",
#     "more"=>
# {"name"=>"Tuuli",
#  "action_mobile"=>"desktop",
#  "action_target"=>"tuuli",
#  "action_referer"=>
#      "https://actions.sumofus.org/pages/show-your-support-for-nationalising-britain-s-water-industry",
#  "action_phone_number"=>"",
#  "action_target_email"=>"tuuli@sumofus.org",
#  "action_express_donation"=>1,
#  "action_box_aldi_customer"=>"0",
#  "action_box_bell_customer"=>"0",
#  "action_box_coop_customer"=>"0",
#  "action_box_lidl_customer"=>"1",
#  "action_dropdown_currency"=>"EUR",
#  "action_textentry_bank_fee"=>"0.63",
#  "action_box_amazon_customer"=>"0",
#  "action_box_kroger_customer"=>"0",
#  "action_box_rogers_customer"=>"0",
#  "action_box_formula_customer"=>"0",
#  "action_box_shaw_customer_nn"=>"0",
#  "action_choice_refund_choice"=>
#      "I want a refund for the amount I was overcharged",
#  "action_box_cineplex_customer"=>"0",
#  "action_box_amazon_shareholder"=>"0",
#  "action_box_kroger_shareholder"=>"0",
#  "action_box_nestle_shareholder"=>"0",
#  "action_box_ontheground_action"=>"0",
#  "action_box_richemont_shareholder"=>"0",
#  "action_dropdown_currency_undercharge"=>"GBP",
#  "action_dropdown_supermarket_customer"=>"sainsburys",
#  "action_textentry_undercharge_bank_fee"=>"0.789",
#  "action_choice_undercharged_refund_option"=>
#      "I don’t want a refund of my donation"},
# "consented_updated_at"=>Thu, 13 Sep 2018 08:27:28 UTC +00:00,
# "consented"=>true},
