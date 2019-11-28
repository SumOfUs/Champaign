# frozen_string_literal: true

require 'rails_helper'

describe 'Express Donation' do
  include Requests::RequestHelpers
  let!(:page) { create(:page, slug: 'hello-world', title: 'Hello World') }
  let(:form)  { create(:form) }

  let(:member)          { create(:member, email: 'test@example.com') }
  let(:customer)        { create(:payment_braintree_customer, member: member) }
  let!(:payment_method) { create(:payment_braintree_payment_method, customer: customer, token: '6vg2vw') }

  before do
    allow(ChampaignQueue).to receive(:push)
    allow(FundingCounter).to receive(:update)
    allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
  end

  describe 'making multiple transactions on the same page with after 10 mins' do
    subject do
      body = {
        payment: {
          amount: 2.00,
          payment_method_id: payment_method.id,
          currency: 'GBP',
          recurring: false
        },
        user: {
          form_id: form.id,
          email: 'test@example.com',
          name: 'John Doe'
        },
        page_id: page.id
      }
      post api_payment_braintree_one_click_path(page.id), params: body
      Timecop.freeze(Time.now + 11.minutes) do
        post api_payment_braintree_one_click_path(page.id), params: body
      end
    end

    it 'creates an action and a transaction for each payment' do
      VCR.use_cassette('express_donation_multiple_transactions') do
        expect(Action.all.count).to eq 0
        expect(Payment::Braintree::Transaction.all.count).to eq 0
        subject
        expect(Action.all.count).to eq 2
        expect(Payment::Braintree::Transaction.all.count).to eq 2
      end
    end
  end

  describe 'making multiple transactions on the same page and amount within 10 mins' do
    subject do
      body = {
        payment: {
          amount: 2.00,
          payment_method_id: payment_method.id,
          currency: 'GBP',
          recurring: false
        },
        user: {
          form_id: form.id,
          email: 'test@example.com',
          name: 'John Doe'
        },
        page_id: page.id
      }
      post api_payment_braintree_one_click_path(page.id), params: body
      Timecop.freeze(Time.now + (1..9).to_a.sample.minutes) do
        post api_payment_braintree_one_click_path(page.id), params: body
      end
    end

    it 'should not allow duplicate donation' do
      VCR.use_cassette('express_donation_multiple_transactions') do
        expect(Action.all.count).to eq 0
        expect(Payment::Braintree::Transaction.all.count).to eq 0
        subject
        expect(Action.all.count).to eq 1
        expect(Payment::Braintree::Transaction.all.count).to eq 1

        expect(response.status).to eq 422
        expect(json_hash['message']).to include(
          "You've just made a donation a few minutes ago. Are you sure, you want to donate again?"
        )
      end
    end
  end

  describe 'making duplicate donation for same page within 10 mins and duplicate attribute' do
    subject do
      body = {
        payment: {
          amount: 2.00,
          payment_method_id: payment_method.id,
          currency: 'GBP',
          recurring: false
        },
        user: {
          form_id: form.id,
          email: 'test@example.com',
          name: 'John Doe'
        },
        page_id: page.id
      }
      post api_payment_braintree_one_click_path(page.id), params: body

      Timecop.freeze(Time.now + (1..9).to_a.sample.minutes) do
        body[:allow_duplicate] = true
        post api_payment_braintree_one_click_path(page.id), params: body
      end
    end

    it 'should allow duplicate donation' do
      VCR.use_cassette('express_donation_multiple_transactions') do
        expect(Action.all.count).to eq 0
        expect(Payment::Braintree::Transaction.all.count).to eq 0
        subject
        expect(Action.all.count).to eq 2
        expect(Payment::Braintree::Transaction.all.count).to eq 2

        expect(response.status).to eq 200
      end
    end
  end

  describe 'subscription' do
    before do
      VCR.use_cassette('braintree_express_donation_subscription') do
        body = {
          payment: {
            amount: 2.00,
            payment_method_id: payment_method.id,
            currency: 'GBP',
            recurring: true
          },
          user: {
            form_id: form.id,
            email: 'test@example.com',
            name: 'John Doe'
          },
          page_id: page.id
        }

        post api_payment_braintree_one_click_path(page.id), params: body
      end
    end

    it 'sets donor status to "recurring_donor"' do
      expect(member.reload.donor_status).to eq('recurring_donor')
    end

    describe 'local record' do
      it 'creates action' do
        action = page.actions.first

        expect(
          action.form_data.deep_symbolize_keys
        ).to include(form_id: form.id.to_s)

        expect(
          Action.first.member.attributes.symbolize_keys
        ).to include(email: 'test@example.com')
      end

      it 'creates subscription' do
        subscription = Payment::Braintree::Subscription.last

        expected_attributes = {
          page_id: page.id,
          subscription_id: /[a-z0-9]{6}/,
          payment_method_id: payment_method.id
        }

        expect(subscription.reload.action).to be_an Action
        expect(subscription.attributes.symbolize_keys)
          .to include(expected_attributes)
      end
    end
  end

  context 'Braintree Error responses' do
    describe 'transaction' do
      before do
        VCR.use_cassette('express_donations_invalid_payment_method') do
          result = Braintree::Transaction.sale(
            payment_method_nonce: 'fake-processor-declined-visa-nonce'
          )

          allow_any_instance_of(PaymentProcessor::Braintree::OneClick).to(
            receive(:run).and_return(result)
          )

          body = {
            payment: {
              amount: 2.00,
              payment_method_id: payment_method.id,
              currency: 'GBP',
              recurring: false
            },
            user: {
              form_id: form.id,
              email: 'test@example.com',
              name: 'John Doe'
            },
            page_id: page.id
          }

          post api_payment_braintree_one_click_path(page.id), params: body
        end
      end

      it 'responds with a 422 status code' do
        expect(response.status).to eq(422)
      end

      it 'body contains errors serialised' do
        expect(json_hash).to include('errors')
        expect(json_hash).to satisfy { |v| !v['errors'].empty? }
      end

      it 'body contains an error message' do
        expect(json_hash).to include('message')
      end

      it 'body contains braintree params' do
        expect(json_hash).to include('params')
      end
    end
  end

  describe 'transaction' do
    before do
      allow(Braintree::Transaction).to receive(:sale).and_call_original
      VCR.use_cassette('braintree_express_donation') do
        body = {
          payment: {
            amount: 2.00,
            payment_method_id: payment_method.id,
            currency: 'gbp',
            recurring: false
          },
          user: {
            form_id: form.id,
            email: 'test@example.com',
            name: 'John Doe'
          },
          page_id: page.id
        }

        post api_payment_braintree_one_click_path(page.id), params: body
      end
    end

    describe 'local record' do
      it 'creates action' do
        action = page.actions.first

        expect(
          action.form_data.deep_symbolize_keys
        ).to include(form_id: form.id.to_s)

        expect(
          Action.first.member.attributes.symbolize_keys
        ).to include(email: 'test@example.com')
      end

      it 'creates transaction' do
        expected_attributes = {
          transaction_type: 'sale',
          transaction_id: /[a-z0-9]{8}/,
          page_id: page.id
        }

        transaction = payment_method.transactions.first.attributes.symbolize_keys
        expect(transaction).to include(expected_attributes)
      end

      it 'sets donor status to "donor"' do
        expect(member.reload.donor_status).to eq('donor')
      end
    end

    it 'creates transaction on braintree' do
      expect(payment_method.customer).to eq(customer)
    end

    it 'posts a donation to the queue with action_express_donation custom field' do
      expect(ChampaignQueue).to have_received(:push)
        .with(
          {
            type: 'donation',
            payment_provider: 'braintree',
            params: {
              donationpage: {
                name: 'hello-world-donation',
                payment_account: 'Braintree GBP'
              },
              order: hash_including(amount: '2.0',
                                    card_num: '1234',
                                    exp_date_month: '12',
                                    exp_date_year: '2050',
                                    trans_id: 'pm403zy1'),
              action: hash_including(fields: hash_including(action_express_donation: 1)),
              user: hash_including(first_name: 'John',
                                   last_name: 'Doe',
                                   email: 'test@example.com',
                                   user_express_cookie: 1,
                                   user_express_account: 0),
              referring_akid: nil
            },
            meta: hash_including({})
          },
          { group_id: /action:\d+/ }
        )
    end

    it 'submits the transaction for settlement' do
      expect(Braintree::Transaction).to have_received(:sale).with(hash_including(
        options: { submit_for_settlement: true }
      ))
    end

    it 'calls the Braintree API with the merchant_account_id' do
      expect(Braintree::Transaction).to have_received(:sale).with(hash_including(
        merchant_account_id: 'GBP'
      ))
    end
  end
end

describe 'Braintree API' do
  let(:page) do
    create(:page,
           title: 'Cash rules everything around me',
           follow_up_plan: :with_liquid,
           follow_up_liquid_layout: follow_up_liquid_layout)
  end
  let(:follow_up_liquid_layout) { create :liquid_layout }
  let(:follow_up_url) { "/a/cash-rules-everything-around-me/follow-up?member_id=#{Member.last.id}" }
  let(:form) { create(:form) }
  let(:four_digits) { /[0-9]{4}/ }
  let(:token_format) { /[a-z0-9]{1,36}/i }
  let(:user_params) do
    {
      form_id: '100',
      name: 'Bernie Sanders',
      email: 'itsme@feelthebern.org',
      postal: '11225',
      phone: '2135551234',
      address1: '25 Elm Drive',
      akid: '1234.5678.9910',
      source: 'fb',
      action_registered_voter: '1',
      country: 'US'
    }
  end

  let(:meta) do
    hash_including(title: 'Cash rules everything around me',
                   uri: '/a/cash-rules-everything-around-me',
                   slug: 'cash-rules-everything-around-me',
                   first_name: 'Bernie',
                   last_name: 'Sanders',
                   country: 'United States',
                   action_id: instance_of(Integer))
  end

  let(:action_express_donation) { 0 }
  let(:user_express_cookie) { 0 }

  let(:donation_push_params) do
    {
      type: 'donation',
      meta: meta,
      payment_provider: 'braintree',
      params: {
        donationpage: {
          name: 'cash-rules-everything-around-me-donation',
          payment_account: 'Braintree EUR'
        },
        order: hash_including(
          amount: amount.to_s,
          card_num: '1881',
          card_code: '007',
          exp_date_month: '12',
          exp_date_year: '2020',
          currency: 'EUR'
        ),
        user: hash_including(
          email: 'itsme@feelthebern.org',
          country: 'United States',
          postal: '11225',
          address1: '25 Elm Drive',
          first_name: 'Bernie',
          last_name: 'Sanders',
          phone: '2135551234',
          akid: '1234.5678.9910',
          source: 'fb',
          user_en: 1,
          user_express_cookie: user_express_cookie
        ),
        action: {
          source: 'fb',
          fields: hash_including(
            action_registered_voter: '1',
            action_mobile: 'desktop',
            action_express_donation: action_express_donation
          )
        },
        referring_akid: nil
      }
    }
  end

  before :each do
    allow(ChampaignQueue).to receive(:push)
    allow(Analytics::Page).to receive(:increment)
    allow(MobileDetector).to receive(:detect).and_return(action_mobile: 'desktop')
    allow(FundingCounter).to receive(:update)
    allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
  end

  describe 'making a transaction' do
    context 'successfully' do
      describe 'making multiple transactions on the same page' do
        let(:first_donation) do
          {
            currency: 'EUR',
            payment_method_nonce: 'fake-valid-nonce',
            recurring: false,
            amount: 2.00,
            store_in_vault: false,
            user: user_params
          }
        end
        let(:second_donation) do
          {
            currency: 'EUR',
            payment_method_nonce: 'fake-valid-nonce',
            recurring: false,
            amount: 5.00,
            store_in_vault: false,
            user: user_params
          }
        end

        subject do
          post api_payment_braintree_transaction_path(page.id), params: first_donation
          post api_payment_braintree_transaction_path(page.id), params: second_donation
        end

        it 'creates a transaction for each payment' do
          VCR.use_cassette('braintree_multiple_transactions') do
            expect(Action.all.count).to eq 0
            expect(Payment::Braintree::Transaction.all.count).to eq 0
            subject
            expect(Action.all.count).to eq 2
            expect(Payment::Braintree::Transaction.all.count).to eq 2
          end
        end
      end

      describe 'with whitelisted action fields' do
        let(:params) do
          {
            currency: 'EUR',
            payment_method_nonce: 'fake-valid-nonce',
            recurring: false,
            amount: 2.00,
            store_in_vault: false,
            user: user_params,
            extra_action_fields: {
              action_test_variant: 'test_variant_name'
            }
          }
        end

        it 'creates an action with the extra parameters' do
          VCR.use_cassette('braintree_transaction whitelisted_fields') do
            post api_payment_braintree_transaction_path(page.id), params: params
            expect(Action.last.form_data['action_test_variant']).to eq('test_variant_name')
          end
        end
      end

      describe "without storing in Braintree's vault" do
        let(:params) do
          {
            currency: 'EUR',
            payment_method_nonce: 'fake-valid-nonce',
            recurring: false,
            amount: 2.00,
            store_in_vault: false,
            user: user_params
          }
        end

        before do
          VCR.use_cassette('braintree_transaction no_vault') do
            post api_payment_braintree_transaction_path(page.id), params: params
          end
        end

        it 'no customer is created' do
          expect(Payment::Braintree::Customer.all).to be_empty
        end

        it 'no payment method is created' do
          expect(Payment::Braintree::PaymentMethod.all).to be_empty
        end

        it 'transaction is created' do
          transaction = Payment::Braintree::Transaction.first

          expect(transaction.attributes).to include({
            currency: 'EUR',
            customer_id: nil
          }.stringify_keys)
        end

        it 'pushes a new donation action to the ActionKit queue' do
          payload = hash_including(
            type: 'donation',
            payment_provider: 'braintree',
            params: {
              donationpage: {
                name: 'cash-rules-everything-around-me-donation',
                payment_account: 'Braintree EUR'
              },
              order: hash_including(amount: '2.0', trans_id: '6c9xdhg9'),
              action: {
                source: 'fb',
                fields: {
                  action_registered_voter: '1',
                  action_mobile: 'desktop',
                  action_express_donation: 0
                }
              },
              user: hash_including(
                first_name: 'Bernie',
                last_name: 'Sanders',
                email: 'itsme@feelthebern.org',
                user_express_cookie: 0
              ),
              referring_akid: nil
            }
          )
          expect(ChampaignQueue).to have_received(:push)
            .with(payload, group_id: /action:\d+/)
        end
      end

      describe "with storing in Braintree's vault" do
        let(:basic_params) do
          {
            currency: 'EUR',
            payment_method_nonce: 'fake-valid-nonce',
            amount: '2.00',
            recurring: false,
            store_in_vault: true
          }
        end

        let(:user_express_cookie) { 1 }

        context 'when Member exists' do
          let!(:member) { create :member, email: user_params[:email], postal: nil, actionkit_user_id: 'woo_actionkit' }

          context 'when BraintreeCustomer exists' do
            let!(:customer) { create :payment_braintree_customer, member: member, customer_id: 'test', card_last_4: '4843' }

            context 'with basic params' do
              let(:amount) { 23.20 } # to avoid duplicate donations recording specs
              let(:params) { basic_params.merge(user: user_params, amount: amount) }
              subject do
                VCR.use_cassette('transaction success basic existing customer') do
                  post api_payment_braintree_transaction_path(page.id), params: params
                end
              end

              it 'increments redis counters' do
                expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
                subject
              end

              it 'stores token to cookie' do
                subject
                expect(response.cookies['payment_methods']).to match(/\W+/)
              end

              it 'creates an Action associated with the Page and Member' do
                expect { subject }.to change { Action.count }.by 1
                expect(Action.last.page).to eq page
                expect(Action.last.member).to eq member
              end

              it 'stores amount, currency, card_num, is_subscription, and transaction_id in form_data on the Action' do
                expect { subject }.to change { Action.count }.by 1
                form_data = Action.last.form_data
                expect(form_data['card_num']).to eq '1881'
                expect(form_data['is_subscription']).to eq false
                expect(form_data['amount']).to eq amount.to_s
                expect(form_data['currency']).to eq 'EUR'
                expect(form_data['transaction_id']).to eq Payment::Braintree::Transaction.last.transaction_id
              end

              it 'creates a Transaction associated with the page storing relevant info' do
                expect { subject }.to change { Payment::Braintree::Transaction.count }.by 1
                transaction = Payment::Braintree::Transaction.last
                expect(transaction.page).to eq page
                expect(transaction.amount).to eq amount
                expect(transaction.currency).to eq 'EUR'
                expect(transaction.merchant_account_id).to eq 'EUR'
                expect(transaction.payment_instrument_type).to eq 'credit_card'
                expect(transaction.transaction_type).to eq 'sale'
                expect(transaction.customer_id).to eq customer.customer_id
                expect(transaction.customer).to eq customer
                expect(transaction.status).to eq 'success'

                expect(Payment::Braintree::PaymentMethod.find(transaction.payment_method_id)
                       .token).to match a_string_matching(token_format)
                expect(transaction.transaction_id).to match a_string_matching(token_format)
              end

              it 'updates Payment::Braintree::Customer with new token and last_4' do
                previous_token = customer.default_payment_method
                previous_last_4 = customer.card_last_4
                expect { subject }.to change { Payment::Braintree::Customer.count }.by 0
                Payment::Braintree::PaymentMethod.last
                customer.reload
                expect(customer.default_payment_method).to_not eq previous_token
                expect(customer.default_payment_method).to eq Payment::Braintree::PaymentMethod.last
                expect(customer.card_last_4).to match a_string_matching(four_digits)
                expect(customer.card_last_4).not_to eq previous_last_4
              end

              it 'posts donation action to queue with key data' do
                subject
                expect(ChampaignQueue).to have_received(:push)
                  .with(donation_push_params, group_id: /action:\d+/)
              end

              it 'increments action count on page' do
                expect { subject }.to change { page.reload.action_count }.by 1
              end

              it 'passes the params to braintree' do
                allow(Braintree::Transaction).to receive(:sale).and_call_original
                subject
                expect(Braintree::Transaction).to have_received(:sale).with(amount: amount,
                                                                            payment_method_nonce: 'fake-valid-nonce',
                                                                            merchant_account_id: 'EUR',
                                                                            device_data: {},
                                                                            options: {
                                                                              submit_for_settlement: true,
                                                                              store_in_vault_on_success: true
                                                                            },
                                                                            customer: {
                                                                              first_name: 'Bernie',
                                                                              last_name: 'Sanders',
                                                                              email: 'itsme@feelthebern.org'
                                                                            },
                                                                            billing: {
                                                                              first_name: 'Bernie',
                                                                              last_name: 'Sanders',
                                                                              street_address: '25 Elm Drive',
                                                                              postal_code: '11225',
                                                                              country_code_alpha2: 'US'
                                                                            },
                                                                            customer_id: customer.customer_id)
              end

              it 'leaves a cookie with the member_id' do
                expect(cookies['member_id']).to eq nil
                subject

                # we can't access signed cookies in request specs, so check for hashed value
                expect(cookies['member_id']).not_to eq nil
                expect(cookies['member_id'].length).to be > 20
              end

              it 'updates the Member’s fields with any new data' do
                expect(member.first_name).not_to eq 'Bernie'
                expect(member.last_name).not_to eq 'Sanders'
                expect(member.postal).to eq nil
                expect(member.donor_status).to eq 'nondonor'
                expect { subject }.to change { Member.count }.by 0
                member.reload
                expect(member.first_name).to eq 'Bernie'
                expect(member.last_name).to eq 'Sanders'
                expect(member.postal).to eq '11225'
                expect(member.donor_status).to eq 'donor'
              end

              it 'responds successfully with transaction_id' do
                subject
                transaction_id = Payment::Braintree::Transaction.last.transaction_id
                expect(response.status).to eq 200
                data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: page.id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, transaction_id: transaction_id }
                expect(response.body).to eq(data.to_json)
              end
            end

            context 'with Paypal' do
              let(:amount) { 29.20 } # to avoid duplicate donations recording specs
              let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount, store_in_vault: true) }

              subject do
                VCR.use_cassette('transaction success paypal existing customer') do
                  post api_payment_braintree_transaction_path(page.id), params: params
                end
              end

              it 'creates a Transaction associated with the page storing relevant info' do
                expect { subject }.to change { Payment::Braintree::Transaction.count }.by 1
                transaction = Payment::Braintree::Transaction.last

                expect(transaction.page).to eq page
                expect(transaction.amount).to eq amount
                expect(transaction.currency).to eq 'EUR'
                expect(transaction.merchant_account_id).to eq 'EUR'
                expect(transaction.payment_instrument_type).to eq 'paypal_account'
                expect(transaction.transaction_type).to eq 'sale'
                expect(transaction.customer_id).to eq customer.customer_id
                expect(transaction.customer).to eq customer
                expect(transaction.status).to eq 'success'

                expect(transaction.payment_method.token).to match a_string_matching(token_format)
                expect(transaction.transaction_id).to match a_string_matching(token_format)
              end

              it 'updates Payment::Braintree::Customer with new token and PYPL for last_4' do
                previous_token = customer.default_payment_method
                previous_last_4 = customer.card_last_4
                expect { subject }.to change { Payment::Braintree::Customer.count }.by 0
                customer.reload
                expect(customer.default_payment_method.token).to match a_string_matching(token_format)
                expect(customer.default_payment_method).to eq Payment::Braintree::PaymentMethod.last
                expect(customer.default_payment_method).not_to eq previous_token
                expect(customer.card_last_4).to eq 'PYPL'
              end

              it 'stores PYPL as card_num on the Action' do
                expect { subject }.to change { Action.count }.by 1
                form_data = Action.last.form_data
                expect(form_data['card_num']).to eq 'PYPL'
                expect(form_data['is_subscription']).to eq false
                expect(form_data['amount']).to eq amount.to_s
                expect(form_data['currency']).to eq 'EUR'
                expect(form_data['transaction_id']).to eq Payment::Braintree::Transaction.last.transaction_id
              end

              it 'passes PYPL as card_num to queue' do
                subject
                expect(ChampaignQueue).to have_received(:push).with(a_hash_including(
                  params: a_hash_including(order: a_hash_including(card_num: 'PYPL'))
                ), group_id: /action:\d+/)
              end

              it 'responds successfully with transaction_id' do
                subject
                transaction = Payment::Braintree::Transaction.last
                member = transaction.customer.member
                expect(response.status).to eq 200
                data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: page.id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, transaction_id: transaction.transaction_id }
                expect(response.body).to eq(data.to_json)
              end

              it 'persists payment_method' do
                subject

                payment_method = Payment::Braintree::PaymentMethod.first

                expect(payment_method.attributes).to include({
                  token: token_format,
                  instrument_type: 'paypal_account',
                  email: 'payer@example.com'
                }.stringify_keys)
              end
            end
          end

          context 'when BraintreeCustomer is new' do
            context 'with basic params' do
              let(:amount) { 13.20 } # to avoid duplicate donations recording specs
              let(:params) { basic_params.merge(user: user_params, amount: amount) }
              subject do
                VCR.use_cassette('transaction success basic new customer') do
                  post api_payment_braintree_transaction_path(page.id), params: params
                end
              end

              it 'persists payment method for customer' do
                subject

                payment_method = Payment::Braintree::PaymentMethod.first

                expect(payment_method.attributes).to include({
                  last_4: '1881',
                  token: token_format,
                  card_type: 'Visa',
                  bin: /\d{6}/,
                  expiration_date: %r{\d{2}/\d{4}},
                  instrument_type: 'credit_card'
                }.stringify_keys)
              end

              it 'creates an Action associated with the Page and Member' do
                expect { subject }.to change { Action.count }.by 1
                expect(Action.last.page).to eq page
                expect(Action.last.member).to eq member
              end

              it 'stores amount, currency, card_num, is_subscription, and transaction_id in form_data on the Action' do
                expect { subject }.to change { Action.count }.by 1
                form_data = Action.last.form_data
                expect(form_data['card_num']).to eq '1881'
                expect(form_data['is_subscription']).to eq false
                expect(form_data['amount']).to eq amount.to_s
                expect(form_data['currency']).to eq 'EUR'
                expect(form_data['transaction_id']).to eq Payment::Braintree::Transaction.last.transaction_id
                expect(form_data).to_not include('recurrence_number')
              end

              it 'creates a Transaction associated with the page storing relevant info' do
                expect { subject }.to change { Payment::Braintree::Transaction.count }.by 1
                transaction = Payment::Braintree::Transaction.last

                expect(transaction.page).to eq page
                expect(transaction.amount).to eq amount
                expect(transaction.currency).to eq 'EUR'
                expect(transaction.merchant_account_id).to eq 'EUR'
                expect(transaction.payment_instrument_type).to eq 'credit_card'
                expect(transaction.transaction_type).to eq 'sale'
                expect(transaction.customer_id).to eq Payment::Braintree::Customer.last.customer_id
                expect(transaction.status).to eq 'success'

                expect(Payment::Braintree::PaymentMethod.find(transaction.payment_method_id)
                       .token).to match a_string_matching(token_format)
                expect(transaction.transaction_id).to match a_string_matching(token_format)
              end

              it 'creates new Payment::Braintree::Customer including token, customer_id, and last four for credit card' do
                expect { subject }.to change { Payment::Braintree::Customer.count }.by 1
                customer = Payment::Braintree::Customer.last
                expect(customer.customer_id).not_to be_blank
                expect(customer.card_last_4).to eq '1881'
                expect(customer.default_payment_method).not_to be_blank
                expect(customer.email).to eq user_params[:email]
              end

              it 'posts donation action to queue with key data' do
                subject
                expect(ChampaignQueue).to have_received(:push)
                  .with(donation_push_params, group_id: /action:\d+/)
              end

              it 'increments action count on page' do
                expect { subject }.to change { page.reload.action_count }.by 1
              end

              it 'passes the params to braintree' do
                allow(Braintree::Transaction).to receive(:sale).and_call_original
                subject
                expect(Braintree::Transaction).to have_received(:sale).with(amount: amount,
                                                                            payment_method_nonce: 'fake-valid-nonce',
                                                                            merchant_account_id: 'EUR',
                                                                            device_data: {},
                                                                            options: {
                                                                              submit_for_settlement: true,
                                                                              store_in_vault_on_success: true
                                                                            },
                                                                            customer: {
                                                                              first_name: 'Bernie',
                                                                              last_name: 'Sanders',
                                                                              email: 'itsme@feelthebern.org'
                                                                            },
                                                                            billing: {
                                                                              first_name: 'Bernie',
                                                                              last_name: 'Sanders',
                                                                              street_address: '25 Elm Drive',
                                                                              postal_code: '11225',
                                                                              country_code_alpha2: 'US'
                                                                            })
              end

              it 'leaves a cookie with the member_id' do
                expect(cookies['member_id']).to eq nil
                subject

                # we can't access signed cookies in request specs, so check for hashed value
                expect(cookies['member_id']).not_to eq nil
                expect(cookies['member_id'].length).to be > 20
              end

              it 'updates the Member’s fields with any new data' do
                expect(member.first_name).not_to eq 'Bernie'
                expect(member.last_name).not_to eq 'Sanders'
                expect(member.postal).to eq nil
                expect { subject }.to change { Member.count }.by 0
                member.reload
                expect(member.first_name).to eq 'Bernie'
                expect(member.last_name).to eq 'Sanders'
                expect(member.postal).to eq '11225'
              end

              it 'responds successfully with transaction_id' do
                subject
                transaction = Payment::Braintree::Transaction.last
                member = transaction.customer.member
                expect(response.status).to eq 200
                data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: page.id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, transaction_id: transaction.transaction_id }
                expect(response.body).to eq(data.to_json)
              end
            end

            context 'with Paypal' do
              let(:amount) { 19.20 } # to avoid duplicate donations recording specs
              let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

              subject do
                VCR.use_cassette('transaction success paypal new customer') do
                  post api_payment_braintree_transaction_path(page.id), params: params
                end
              end

              it 'creates a Transaction associated with the page storing relevant info' do
                expect { subject }.to change { Payment::Braintree::Transaction.count }.by 1
                transaction = Payment::Braintree::Transaction.last

                expect(transaction.page).to eq page
                expect(transaction.amount).to eq amount
                expect(transaction.currency).to eq 'EUR'
                expect(transaction.merchant_account_id).to eq 'EUR'
                expect(transaction.payment_instrument_type).to eq 'paypal_account'
                expect(transaction.transaction_type).to eq 'sale'
                expect(transaction.customer_id).to eq Payment::Braintree::Customer.last.customer_id
                expect(transaction.status).to eq 'success'

                expect(Payment::Braintree::PaymentMethod.find(transaction.payment_method_id)
                       .token).to match a_string_matching(token_format)
                expect(transaction.transaction_id).to match a_string_matching(token_format)
              end

              it 'creates a Payment::Braintree::Customer with customer_id and PYPL for last 4' do
                expect { subject }.to change { Payment::Braintree::Customer.count }.by 1
                customer = Payment::Braintree::Customer.last
                expect(customer.customer_id).not_to be_blank
                expect(customer.card_last_4).to eq 'PYPL'
                expect(customer.default_payment_method).not_to be_blank
                expect(customer.email).to eq user_params[:email]
              end

              it 'stores PYPL as card_num on the Action' do
                expect { subject }.to change { Action.count }.by 1
                form_data = Action.last.form_data
                expect(form_data['card_num']).to eq 'PYPL'
                expect(form_data['is_subscription']).to eq false
                expect(form_data['amount']).to eq amount.to_s
                expect(form_data['currency']).to eq 'EUR'
                expect(form_data['transaction_id']).to eq Payment::Braintree::Transaction.last.transaction_id
              end

              it 'passes PYPL as card_num to queue' do
                subject
                expect(ChampaignQueue).to have_received(:push).with(a_hash_including(
                  params: a_hash_including(order: a_hash_including(card_num: 'PYPL'))
                ), group_id: /action:\d+/)
              end

              it 'responds successfully with transaction_id' do
                subject
                transaction = Payment::Braintree::Transaction.last
                member = transaction.customer.member
                expect(response.status).to eq 200
                data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: page.id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, transaction_id: transaction.transaction_id }
                expect(response.body).to eq(data.to_json)
              end
            end
          end
        end

        context 'when Member is new' do
          context 'when BraintreeCustomer is new' do
            context 'with basic params' do
              # we're using the same casette as above anyway, so we're only running specs
              # relevant to the new member

              let(:amount) { 13.20 } # to avoid duplicate donations recording specs
              let(:params) { basic_params.merge(user: user_params, amount: amount) }

              subject do
                VCR.use_cassette('transaction success basic new customer') do
                  post api_payment_braintree_transaction_path(page.id), params: params
                end
              end

              it 'increments redis counters' do
                expect(Analytics::Page).to receive(:increment).with(page.id, new_member: true)
                subject
              end

              it 'creates an Action associated with the Page and Member' do
                expect { subject }.to change { Action.count }.by 1
                expect(Action.last.page).to eq page
                expect(Action.last.member).to eq Member.last
              end

              it 'leaves a cookie with the member_id' do
                expect(cookies['member_id']).to eq nil
                subject

                # we can't access signed cookies in request specs, so check for hashed value
                expect(cookies['member_id']).not_to eq nil
                expect(cookies['member_id'].length).to be > 20
              end

              it 'populates the Member’s fields with form data' do
                expect { subject }.to change { Member.count }.by 1
                member = Member.last
                expect(member.first_name).to eq 'Bernie'
                expect(member.last_name).to eq 'Sanders'
                expect(member.postal).to eq '11225'
                expect(member.donor_status).to eq 'donor'
              end

              it 'responds successfully with transaction_id' do
                subject
                transaction = Payment::Braintree::Transaction.last
                member = transaction.customer.member
                expect(response.status).to eq 200
                data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: page.id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, transaction_id: transaction.transaction_id }
                expect(response.body).to eq(data.to_json)
              end
            end
          end
        end
      end
    end
  end

  describe 'making a subscription' do
    describe 'successfully' do
      let(:basic_params) do
        {
          currency: 'EUR',
          payment_method_nonce: 'fake-valid-nonce',
          # amount: amount, # should override for each casette to avoid duplicates
          recurring: true
        }
      end

      let(:donation_push_params) do
        {
          type: 'donation',
          payment_provider: 'braintree',
          meta: meta,
          params: {
            donationpage: {
              name: 'cash-rules-everything-around-me-donation',
              payment_account: 'Braintree EUR'
            },
            order: {
              amount: amount.to_s,
              card_num: '1881',
              card_code: '007',
              exp_date_month: '12',
              exp_date_year: '2020',
              currency: 'EUR',
              trans_id: /[a-z0-9]{6}/
            },
            user: {
              email: 'itsme@feelthebern.org',
              country: 'United States',
              postal: '11225',
              address1: '25 Elm Drive',
              name: 'Bernie Sanders',
              first_name: 'Bernie',
              last_name: 'Sanders',
              phone: '2135551234',
              akid: '1234.5678.9910',
              source: 'fb',
              user_en: 1,
              user_express_cookie: user_express_cookie,
              user_express_account: 0
            },
            action: {
              source: 'fb',
              fields: {
                action_registered_voter: '1',
                action_mobile: 'desktop',
                action_express_donation: 0
              }
            },
            referring_akid: nil
          }
        }
      end

      context 'when Member exists' do
        let!(:member) { create :member, email: user_params[:email], postal: nil }

        before do
          donation_push_params[:params][:order][:recurring_id] = /[a-z0-9]{6}/
        end

        context 'when BraintreeCustomer exists' do
          let!(:customer) { create :payment_braintree_customer, member: member, customer_id: '29823405', card_last_4: '4843' }

          context 'with basic params' do
            let(:amount) { 823.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }

            subject do
              VCR.use_cassette('subscription success basic existing customer') do
                post api_payment_braintree_transaction_path(page.id), params: params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it 'creates an Action associated with the Page and Member' do
              expect { subject }.to change { Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq member
            end

            it 'stores amount, currency, card_num, is_subscription, transaction_id, and subscription_id in form_data on the Action' do
              expect { subject }.to change { Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq '1881'
              expect(form_data['recurrence_number']).to eq(0)
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::Braintree::Subscription.last.subscription_id
            end

            it 'does not create a transaction' do
              expect { subject }.not_to change { Payment::Braintree::Transaction.count }
            end

            it 'creates a Subscription associated with the page storing relevant info' do
              expect { subject }.to change { Payment::Braintree::Subscription.count }.by 1
              subscription = Payment::Braintree::Subscription.last

              expect(subscription.amount).to eq amount
              expect(subscription.currency).to eq 'EUR'
              expect(subscription.merchant_account_id).to eq 'EUR'
              expect(subscription.subscription_id).to match a_string_matching(token_format)
              expect(subscription.page).to eq page
              expect(subscription.action).to eq Action.last
            end

            it 'creates a Subscription associated with a customer and payment method' do
              expect { subject }.to change { Payment::Braintree::Subscription.count }.by 1
              expect { subject }.to_not change { Payment::Braintree::PaymentMethod.count }
              expect { subject }.to_not change { Payment::Braintree::Customer.count }

              subscription = Payment::Braintree::Subscription.last
              payment_method = Payment::Braintree::PaymentMethod.last

              expect(subscription.customer).to eq customer
              expect(subscription.payment_method).to eq(payment_method)
              expect(customer.payment_methods).to include(payment_method)
            end

            it 'updates Payment::Braintree::Customer with new token and last_4' do
              previous_token = customer.default_payment_method
              previous_last_4 = customer.card_last_4
              expect { subject }.to change { Payment::Braintree::Customer.count }.by 0
              customer.reload
              expect(customer.default_payment_method.token).to match a_string_matching(token_format)
              expect(customer.default_payment_method).to eq Payment::Braintree::PaymentMethod.last
              expect(customer.default_payment_method).not_to eq previous_token
              expect(customer.card_last_4).to match a_string_matching(four_digits)
              expect(customer.card_last_4).not_to eq previous_last_4
            end

            it 'posts donation action to queue with key data' do
              subject
              expect(ChampaignQueue).to have_received(:push)
                .with(donation_push_params, group_id: /action:\d+/)
            end

            it 'increments action count on page' do
              expect { subject }.to change { page.reload.action_count }.by 1
            end

            it 'passes the subscription params to braintree' do
              allow(Braintree::Subscription).to receive(:create).and_call_original
              subject
              expect(Braintree::Subscription).to have_received(:create).with(price: amount,
                                                                             payment_method_token: a_string_matching(token_format),
                                                                             merchant_account_id: 'EUR',
                                                                             plan_id: 'EUR')
            end

            it 'passes the customer params to braintree' do
              allow(Braintree::Customer).to receive(:update).and_call_original
              subject
              expect(Braintree::Customer).to have_received(:update).with(customer.customer_id, first_name: 'Bernie',
                                                                                               last_name: 'Sanders',
                                                                                               email: 'itsme@feelthebern.org')
            end

            it 'passes the payment params to braintree' do
              allow(Braintree::PaymentMethod).to receive(:create).and_call_original
              subject
              expect(Braintree::PaymentMethod).to have_received(:create).with(payment_method_nonce: 'fake-valid-nonce',
                                                                              customer_id: customer.customer_id,
                                                                              device_data: {},
                                                                              options: {
                                                                                verify_card: true
                                                                              },
                                                                              billing_address: {
                                                                                first_name: 'Bernie',
                                                                                last_name: 'Sanders',
                                                                                street_address: '25 Elm Drive',
                                                                                postal_code: '11225',
                                                                                country_code_alpha2: 'US'
                                                                              })
            end

            it 'leaves a cookie with the member_id' do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it 'updates the Member’s fields with any new data' do
              expect(member.first_name).not_to eq 'Bernie'
              expect(member.last_name).not_to eq 'Sanders'
              expect(member.postal).to eq nil
              expect(member.donor_status).to eq 'nondonor'
              expect { subject }.to change { Member.count }.by 0
              member.reload
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
              expect(member.donor_status).to eq 'recurring_donor'
            end

            it 'responds successfully with follow_up_url and subscription_id' do
              subject
              subscription = Payment::Braintree::Subscription.last
              member = subscription.customer.member

              expect(response.status).to eq 200
              data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: subscription.page_id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, subscription_id: subscription.subscription_id }
              expect(response.body).to eq(data.to_json)
            end
          end

          context 'with extra action params' do
            let(:amount) { 823.20 } # to avoid duplicate donations recording specs
            let(:params) {
              basic_params.merge user: user_params,
                                 amount: amount,
                                 extra_action_fields: {
                                   action_test_variant: 'test_variant_name'
                                 }
            }

            it 'creates an action with the extra parameters' do
              VCR.use_cassette('braintree_subscription whitelisted_fields') do
                post api_payment_braintree_transaction_path(page.id), params: params
                expect(Action.last.form_data['action_test_variant']).to eq('test_variant_name')
              end
            end
          end

          context 'with Paypal' do
            let(:amount) { 829.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

            subject do
              VCR.use_cassette('subscription success paypal existing customer') do
                params[:store_in_vault] = true
                post api_payment_braintree_transaction_path(page.id), params: params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it 'does not create a transaction' do
              expect { subject }.not_to change { Payment::Braintree::Transaction.count }
            end

            it 'updates Payment::Braintree::Customer with new token and PYPL for last_4' do
              previous_token = customer.default_payment_method
              previous_last_4 = customer.card_last_4
              expect { subject }.to change { Payment::Braintree::Customer.count }.by 0
              customer.reload
              expect(customer.default_payment_method.token).to match a_string_matching(token_format)
              expect(customer.default_payment_method).to eq Payment::Braintree::PaymentMethod.last
              expect(customer.default_payment_method).not_to eq previous_token
              expect(customer.card_last_4).to_not eq previous_last_4
              expect(customer.card_last_4).to eq 'PYPL'
            end

            it 'stores PYPL as card_num on the Action' do
              expect { subject }.to change { Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::Braintree::Subscription.last.subscription_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect(ChampaignQueue).to have_received(:push).with(a_hash_including(
                params: a_hash_including(order: a_hash_including(card_num: 'PYPL'))
              ), group_id: /action:\d+/)
            end

            it 'responds successfully with follow_up_url and subscription_id' do
              subject
              subscription = Payment::Braintree::Subscription.last
              member = subscription.customer.member
              expect(response.status).to eq 200
              data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: subscription.page_id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, subscription_id: subscription.subscription_id }
              expect(response.body).to eq(data.to_json)
            end
          end
        end

        context 'when BraintreeCustomer is new' do
          context 'with basic params' do
            let(:amount) { 813.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }

            subject do
              VCR.use_cassette('subscription success basic new customer') do
                post api_payment_braintree_transaction_path(page.id), params: params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it 'creates an Action associated with the Page and Member' do
              expect { subject }.to change { Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq member
            end

            it 'stores amount, currency, card_num, is_subscription, and subscription_id in form_data on the Action' do
              expect { subject }.to change { Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq '1881'
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::Braintree::Subscription.last.subscription_id
            end

            it 'does not create a transaction' do
              expect { subject }.not_to change { Payment::Braintree::Transaction.count }
            end

            it 'creates a Subscription associated with the page storing relevant info' do
              expect { subject }.to change { Payment::Braintree::Subscription.count }.by 1
              subscription = Payment::Braintree::Subscription.last
              expect(subscription.amount).to eq amount
              expect(subscription.currency).to eq 'EUR'
              expect(subscription.merchant_account_id).to eq 'EUR'
              expect(subscription.subscription_id).to match a_string_matching(token_format)
              expect(subscription.page).to eq page
              expect(subscription.action).to eq Action.last
            end

            it 'creates a Payment::Braintree::Customer with new token, customer_id, and last_4' do
              expect { subject }.to change { Payment::Braintree::Customer.count }.by 1
              customer = Payment::Braintree::Customer.last
              expect(customer.customer_id).to match a_string_matching(token_format)
              expect(customer.default_payment_method.token).to match a_string_matching(token_format)
              expect(customer.email).to eq user_params[:email]
              expect(customer.card_last_4).to match a_string_matching(four_digits)
            end

            it 'creates a Subscription associated with the newly created payment method' do
              subject
              subscription = Payment::Braintree::Subscription.last
              customer = Payment::Braintree::Customer.last
              expect(subscription.payment_method).to eq customer.default_payment_method
            end

            it 'posts donation action to queue with key data' do
              subject
              expect(ChampaignQueue).to have_received(:push)
                .with(donation_push_params, group_id: /action:\d+/)
            end

            it 'increments action count on page' do
              expect { subject }.to change { page.reload.action_count }.by 1
            end

            it 'passes the subscription params to braintree' do
              allow(Braintree::Subscription).to receive(:create).and_call_original
              subject
              expect(Braintree::Subscription).to have_received(:create).with(price: amount,
                                                                             payment_method_token: a_string_matching(token_format),
                                                                             merchant_account_id: 'EUR',
                                                                             plan_id: 'EUR')
            end

            it 'passes the customer params and nonce to braintree' do
              allow(Braintree::Customer).to receive(:create).and_call_original
              subject
              expect(Braintree::Customer).to have_received(:create).with(first_name: 'Bernie',
                                                                         last_name: 'Sanders',
                                                                         payment_method_nonce: 'fake-valid-nonce',
                                                                         email: 'itsme@feelthebern.org',
                                                                         credit_card: {
                                                                           billing_address: {
                                                                             first_name: 'Bernie',
                                                                             last_name: 'Sanders',
                                                                             street_address: '25 Elm Drive',
                                                                             postal_code: '11225',
                                                                             country_code_alpha2: 'US'
                                                                           }
                                                                         })
            end

            it 'does not create payment method separately' do
              allow(Braintree::PaymentMethod).to receive(:create).and_call_original
              subject
              expect(Braintree::PaymentMethod).not_to have_received(:create)
            end

            it 'leaves a cookie with the member_id' do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it 'updates the Member’s fields with any new data' do
              expect(member.first_name).not_to eq 'Bernie'
              expect(member.last_name).not_to eq 'Sanders'
              expect(member.postal).to eq nil
              expect { subject }.to change { Member.count }.by 0
              member.reload
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
            end

            it 'responds successfully with follow_up_url and subscription_id' do
              subject
              subscription = Payment::Braintree::Subscription.last
              member = subscription.customer.member
              expect(response.status).to eq 200
              data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: page.id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, subscription_id: subscription.subscription_id }
              expect(response.body).to eq(data.to_json)
            end

            it 'persists payment_method' do
              subject

              payment_method = Payment::Braintree::PaymentMethod.first

              expect(payment_method.attributes).to include({
                token: token_format,
                instrument_type: 'credit_card',
                expiration_date: %r{\d{2}/\d{4}},
                last_4: /\d{4}/,
                bin: /\d{6}/
              }.stringify_keys)
            end
          end

          context 'with Paypal' do
            let(:amount) { 819.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

            subject do
              VCR.use_cassette('subscription success paypal new customer') do
                post api_payment_braintree_transaction_path(page.id), params: params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: false)
              subject
            end

            it 'does not create a transaction' do
              expect { subject }.not_to change { Payment::Braintree::Transaction.count }
            end

            it 'persists payment_method' do
              subject

              payment_method = Payment::Braintree::PaymentMethod.first

              expect(payment_method.attributes).to include({
                token: token_format,
                instrument_type: 'paypal_account',
                email: 'jane.doe@example.com'
              }.stringify_keys)
            end

            it 'creates a Payment::Braintree::Customer with customer_id and PYPL for last 4' do
              expect { subject }.to change { Payment::Braintree::Customer.count }.by 1
              customer = Payment::Braintree::Customer.last
              expect(customer.customer_id).to match a_string_matching(token_format)
              expect(customer.default_payment_method.token).to match a_string_matching(token_format)
              expect(customer.email).to eq user_params[:email]
              expect(customer.reload.card_last_4).to eq 'PYPL'
            end

            it 'stores PYPL as card_num on the Action' do
              expect { subject }.to change { Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['card_num']).to eq 'PYPL'
              expect(form_data['is_subscription']).to eq true
              expect(form_data['amount']).to eq amount.to_s
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['subscription_id']).to eq Payment::Braintree::Subscription.last.subscription_id
            end

            it 'passes PYPL as card_num to queue' do
              subject
              expect(ChampaignQueue).to have_received(:push).with(a_hash_including(
                params: a_hash_including(order: a_hash_including(card_num: 'PYPL'))
              ), group_id: /action:\d+/)
            end

            it 'responds successfully with follow_up_url and subscription_id' do
              subject
              subscription = Payment::Braintree::Subscription.last
              member = subscription.customer.member
              expect(response.status).to eq 200
              data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: subscription.page_id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, subscription_id: subscription.subscription_id }
              expect(response.body).to eq(data.to_json)
            end
          end
        end
      end

      context 'when Member is new' do
        context 'when BraintreeCustomer is new' do
          context 'with basic params' do
            # we're using the same casette as above anyway, so we're only running specs
            # relevant to the new member

            let(:amount) { 813.20 } # to avoid duplicate donations recording specs
            let(:params) { basic_params.merge(user: user_params, amount: amount) }

            subject do
              VCR.use_cassette('subscription success basic new customer') do
                post api_payment_braintree_transaction_path(page.id), params: params
              end
            end

            it 'increments redis counters' do
              expect(Analytics::Page).to receive(:increment).with(page.id, new_member: true)
              subject
            end

            it 'creates an Action associated with the Page and Member' do
              expect { subject }.to change { Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq Member.last
            end

            it 'leaves a cookie with the member_id' do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it 'populates the Member’s fields with form data' do
              expect { subject }.to change { Member.count }.by 1
              member = Member.last
              expect(member.first_name).to eq 'Bernie'
              expect(member.last_name).to eq 'Sanders'
              expect(member.postal).to eq '11225'
              expect(member.donor_status).to eq 'recurring_donor'
            end

            it 'responds successfully with follow_up_url and subscription_id' do
              subject
              subscription = Payment::Braintree::Subscription.last
              member = subscription.customer.member
              expect(response.status).to eq 200
              data = { success: true, tracking: { content_name: 'cash-rules-everything-around-me', status: true, user_id: member.id, page_id: subscription.page_id, value: member.id, currency: 'USD' }, follow_up_url: follow_up_url, subscription_id: subscription.subscription_id }
              expect(response.body).to eq(data.to_json)
            end
          end
        end
      end
    end
  end

  describe 'storing multiple payment method tokens' do
    context 'existing customer' do
      let(:basic_params) do
        {
          currency: 'EUR',
          payment_method_nonce: 'fake-valid-mastercard-nonce',
          recurring: false
        }
      end

      let(:params) { basic_params.merge(user: user_params, amount: 5, store_in_vault: true) }

      subject do
        VCR.use_cassette('transaction_existing_customer_storing_multiple_tokens') do
          post api_payment_braintree_transaction_path(page.id), params: params
        end
      end

      let!(:member)   { create :member, email: user_params[:email], postal: nil }
      let!(:customer) { create(:payment_braintree_customer, member: member, customer_id: 'test', card_last_4: '4843') }

      before do
        3.times do
          Payment::Braintree::PaymentMethod.create(customer: customer)
        end
      end

      it 'supports storing multiple braintree payment method tokens' do
        original_token = customer.default_payment_method
        expect(customer.payment_methods.length).to eq(3)
        expect(customer.payment_methods).to include(original_token)
        expect { subject }.to change { Payment::Braintree::Customer.count }.by(0)

        customer.reload
        expect(customer.payment_methods.length).to eq(4)
        expect(customer.default_payment_method).not_to eq original_token
        expect(customer.payment_methods).to include(original_token, customer.default_payment_method)
      end

      # This spec describes he rather weird expected behavior at the moment, where we create a payment method token every time.
      it 'always creates a new payment method token, even if the same payment method is used' do
        original_token = customer.default_payment_method

        expect(customer.payment_methods.length).to eq(3)
        expect(customer.payment_methods).to include(original_token)
        expect { subject }.to change { Payment::Braintree::Customer.count }.by(0)
        customer.reload
        expect(customer.payment_methods.length).to eq(4)
        expect(customer.default_payment_method).not_to eq original_token
        expect(customer.payment_methods).to include(original_token, customer.default_payment_method)
        new_token = customer.default_payment_method

        VCR.use_cassette('transaction_existing_customer_storing_multiple_tokens_second_request') do
          post api_payment_braintree_transaction_path(page.id), params: params
        end

        customer.reload
        # The same payment method was used, the payment method tokens get incremented anyway. Similarly the default
        # payment method token gets updated to the new token corresponding to the old payment method.
        expect(customer.payment_methods.length).to eq(5)
        expect(customer.default_payment_method).to_not eq new_token
        expect(customer.payment_methods).to include(original_token, new_token, customer.default_payment_method)
        # Each token only has one payment associated with them.
        expect(Payment::Braintree::Transaction.where(payment_method_id: new_token.id).length).to eq(1)
        expect(Payment::Braintree::Transaction.where(payment_method_id: customer.default_payment_method.id).length).to eq(1)
      end
    end

    context 'new customer' do
      let(:params) { basic_params.merge(user: user_params, amount: amount) }
      subject do
        VCR.use_cassette('transaction_existing_customer_storing_multiple_tokens') do
          post api_payment_braintree_transaction_path(page.id), params: params
        end
      end
    end
  end

  describe 'fetching a token' do
    it 'gets a client token' do
      VCR.use_cassette('braintree_client_token') do
        expect { get api_payment_braintree_token_path }.not_to raise_error

        body = JSON.parse(response.body).with_indifferent_access
        expect(body).to have_key(:token)
        expect(body[:token].to_s).to match a_string_matching(/[a-zA-Z0-9=]{5,5000}/)
      end
    end
  end

  describe 'refund' do
    let(:page) { create(:page, publish_status: 'published') }
    let(:refund_ids) {
      %w[pa58afh7 pw4w2sps kpjzcm8t f8b00cv7 peve3se6
         09858t43 grms7qa0 cxfs6r3b]
    }
    let(:transaction_ids) {
      %w[7hye1bz0 m7a8f6v1 fg9v30g8 naxgvz4j
         45zh1tby g68p0rqt 12vk0d01 5w1a2z1g
         7hye1bz0 m7a8f6v1 fg9v30g8 naxgvz4j
         45zh1tby g68p0rqt 12vk0d01 5w1a2z1g]
    }

    context 'with invalid api token' do
      before do
        get '/api/payment/braintree/refund'
      end

      it 'should return forbidden error' do
        expect(response.response_code).to eq 403
      end
    end

    context 'with valid api token' do
      before do
        VCR.use_cassette('background_service_sync_braintree_refunds') do
          get '/api/payment/braintree/refund', params: nil, headers: { 'X-Api-Key' => '1234' }
        end
      end

      it 'should return status ok' do
        expect(response.response_code).to eq 200
      end

      it 'should return unsynced_ids' do
        expect(response_json['refund_ids_synced']).to eql refund_ids
      end
    end

    context 'service running for second time' do
      before do
        transaction_ids.each do |t|
          create(:payment_braintree_transaction, amount: [20, 30, 50].sample,
                                                 status: 'success', currency: 'USD', transaction_id: t,
                                                 page_id: page.id)
        end

        VCR.use_cassette('background_service_sync_braintree_refunds') do
          get '/api/payment/braintree/refund', params: nil, headers: { 'X-Api-Key' => '1234' }
        end

        # run second time
        VCR.use_cassette('background_service_sync_braintree_refunds') do
          get '/api/payment/braintree/refund', params: nil, headers: { 'X-Api-Key' => '1234' }
        end
      end

      it 'should return unsynced_ids' do
        expect(response_json['refund_ids_synced']).to eql []
      end
    end
  end
end
