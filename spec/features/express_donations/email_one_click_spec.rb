# frozen_string_literal: true
require 'rails_helper'
require_relative 'shared_methods'

feature 'Express From Mailing Link' do
  include SharedMethods

  let(:follow_up_layout) { create :liquid_layout, default_follow_up_layout: nil }
  let(:liquid_layout)    { create :liquid_layout, default_follow_up_layout: follow_up_layout }
  let(:donation_page)    { create(:page, slug: 'foo-bar', title: 'Foo Bar', follow_up_liquid_layout: liquid_layout) }

  let(:email)    { 'donor@example.com' }
  let(:member)   { Member.find_by(email: email) }
  let(:customer) { Payment::Braintree::Customer.find_by(email: email) }
  let(:valid_akid) { '25429.9032842.RNP4O4' }

  let(:queue_payload) do
    {
      type: 'donation',
      payment_provider: 'braintree',
      params: {
        donationpage: {
          name: 'foo-bar-donation', payment_account: 'Braintree GBP'
        },
        order: {
          amount: '2.10',
          card_num: '1881',
          card_code: '007',
          exp_date_month: '12',
          exp_date_year: '2020',
          currency: 'GBP'
        },
        action: {
          source: nil,
          fields: { action_express_donation: 1 }
        },
        user: {
          first_name: 'Foo',
          last_name: 'Bar',
          email: 'donor@example.com',
          country: 'United States',
          akid: valid_akid,
          source: nil,
          user_express_cookie: 1,
          user_express_account: @is_authenticated,
          user_en: 1
        }
      },
      meta: a_hash_including(
        title: 'Foo Bar',
        uri: '/a/foo-bar',
        slug: 'foo-bar',
        first_name: 'Foo',
        last_name: 'Bar',
        country: 'United States',
        subscribed_member: false
      )
    }
  end

  before do
    allow(ChampaignQueue).to receive(:push)
  end

  scenario 'Authenticated member makes a one-click donation' do
    store_payment_in_vault
    register_member(member)
    authenticate_member(member.authentication)

    expect(Action.count).to eq(1)
    expect(customer.transactions.count).to eq(1)

    @is_authenticated = 1
    expect(ChampaignQueue).to receive(:push).with(queue_payload)

    VCR.use_cassette('feature_member_email_donation') do
      visit page_path(donation_page, amount: '2.10', currency: 'GBP', akid: valid_akid, one_click: true)
    end

    expect(customer.reload.transactions.count).to eq(2)
    expect(Action.count).to eq(2)

    # Redirects to follow up url for campaign page
    expect(current_url).to match(%r{/foo-bar/follow-up\?member_id=#{member.id}})
  end

  scenario 'Cookied customer makes a one-click donation' do
    store_payment_in_vault

    expect(customer.transactions.count).to eq(1)
    expect(Action.count).to eq(1)

    @is_authenticated = 0
    expect(ChampaignQueue).to receive(:push).with(queue_payload)

    VCR.use_cassette('feature_one_click_cookie') do
      visit page_path(donation_page, amount: '2.10', currency: 'GBP', akid: valid_akid, one_click: true)
    end

    expect(customer.reload.transactions.count).to eq(2)
    expect(Action.count).to eq(2)
    expect(current_url).to match(%r{/member_authentication/new})
  end

  scenario 'Cookied member makes a one-click donation' do
    VCR.use_cassette('feature_one_click_member_no_customer') do
      visit page_path(donation_page, amount: 1.50, currency: 'GBP', one_click: true)
    end

    expect(Action.count).to eq(0)
    expect(current_url).to match(%r{/foo-bar})
  end

  scenario 'Stanger makes a one-click donation' do
    VCR.use_cassette('feature_one_click_stranger') do
      visit page_path(donation_page, amount: 1.50, currency: 'GBP', one_click: true)
    end

    expect(Action.count).to eq(0)
    expect(current_url).to match(%r{/foo-bar})
  end

  scenario 'One-click donation with AKID, but without cookied payment methods' do
    store_payment_in_vault
    store_payment_in_vault(2)

    delete_cookies_from_browser

    VCR.use_cassette('feature_one_click_stranger') do
      expect do
        visit page_path(donation_page, amount: 1.50, currency: 'GBP', one_click: true, akid: valid_akid)
      end.to_not change { customer.transactions.count }.from(2)
    end

    expect(current_url).to match(%r{/foo-bar})
  end
end
