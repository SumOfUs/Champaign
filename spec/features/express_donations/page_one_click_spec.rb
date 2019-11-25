# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_methods'

feature 'One Click From Save Payment Methods from Page' do
  include SharedMethods

  let(:follow_up_layout) { create :liquid_layout, default_follow_up_layout: nil }
  let(:liquid_layout)    { create :liquid_layout, default_follow_up_layout: follow_up_layout }
  let(:donation_page)    { create(:page, slug: 'foo-bar', title: 'Foo Bar', follow_up_liquid_layout: liquid_layout) }

  let(:email)    { 'donor@example.com' }
  let(:member)   { Member.find_by(email: email) }
  let(:customer) { Payment::Braintree::Customer.find_by(email: email) }
  let(:valid_akid) { '25429.9032842.RNP4O4' }

  before do
    allow(ChampaignQueue).to receive(:push)
    allow(FundingCounter).to receive(:update)
    allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
  end

  scenario 'Authenticated member makes an express donation' do
    store_payment_in_vault
    register_member(member)
    authenticate_member(member.authentication)

    expect(Action.count).to eq(1)

    params = {
      payment: {
        amount: 1,
        currency: 'GBP',
        recurring: false,
        payment_method_id: customer.payment_methods.first.id
      },
      user: {
        name: 'Foo Bar',
        email: email
      }
    }

    VCR.use_cassette('feature_member_express_donation') do
      VCR.use_cassette('money_from_oxr') do
        Timecop.freeze(Time.now + 15.minutes) do
          path = api_payment_braintree_one_click_path(donation_page.id)
          page.driver.post path, params
        end
      end
    end

    expect(Action.count).to eq(2)
    expect(customer.transactions.count).to eq(2)
  end

  scenario "Member makes an express donation with another member's payment method" do
    store_payment_in_vault
    register_member(member)
    authenticate_member(member.authentication)

    params = {
      payment: {
        amount: 1,
        currency: 'GBP',
        recurring: false,
        payment_method_id: customer.payment_methods.first.id
      },
      user: {
        name: 'Foo Bar',
        email: 'stranger@example.com'
      }
    }

    delete_cookies_from_browser

    VCR.use_cassette('feature_member_express_donation') do
      VCR.use_cassette('money_from_oxr') do
        path = api_payment_braintree_one_click_path(donation_page.id)
        expect {
          page.driver.post path, params
        }.to raise_error(PaymentProcessor::Exceptions::CustomerNotFound)
      end
    end

    expect(customer.transactions.count).to eq(1)
  end
end
