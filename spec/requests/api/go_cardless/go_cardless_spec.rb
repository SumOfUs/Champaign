# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'

describe 'GoCardless API' do
  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
  let(:usd_amount) { 9.99 }
  let(:gbp_amount) { 11.55 }

  let(:bad_request_errors) do
    [{
      code: 422,
      message: 'Our technical team has been notified. Please double check your info or try a different payment method.'
    }]
  end

  let(:meta) do
    hash_including(title:      'Foo Bar',
                   uri:        '/a/foo-bar',
                   slug:       'foo-bar',
                   first_name: 'Bernie',
                   last_name:  'Sanders',
                   action_id:  instance_of(Fixnum),
                   created_at: be_within(30.seconds).of(Time.now),
                   country: 'United States')
  end

  before :each do
    allow_any_instance_of(Money).to receive(:exchange_to).and_return(
      instance_double(Money, cents: (gbp_amount * 100).to_i)
    )

    allow(MobileDetector).to receive(:detect).and_return(action_mobile: 'tablet')
  end

  describe 'redirect flow' do
    let(:page) { create :page, slug: 'implement-synergistic-cooperation', id: 1 }

    describe 'successful' do
      before :each do
        allow(SecureRandom).to receive(:uuid).and_return('the-session-id')
      end

      subject do
        VCR.use_cassette('go_cardless redirect flow request success') do
          get api_go_cardless_path(page, amount: 3, currency: 'EUR')
        end
      end

      it 'sets the go_cardless_session_id and passes that to the redirect flow' do
        subject
        expect(request.session[:go_cardless_session_id]).to eq 'the-session-id'
        expect(assigns(:flow).redirect_flow_instance.session_token).to eq 'the-session-id'
      end

      it 'passes all url params to the redirect url' do
        subject
        success_redirect_params = Rack::Utils.parse_query(
          URI.parse(assigns(:flow).redirect_flow_instance.success_redirect_url).query
        )
        request.params.each_pair do |key, val|
          next if key =~ /controller|action/
          expect(success_redirect_params[key]).to eq val
        end
      end

      it 'passes the description to go_cardless' do
        subject
        expect(assigns(:flow).redirect_flow_instance.description).to match(/You are donating €3.00/)
      end

      it 'redirects to a page hosted on GoCardless' do
        subject
        expect(response.status).to be 302
        expect(response.body).to match(%r{You are being <a href=\"https:\/\/pay-sandbox.gocardless.com\/flow\/RE[0-9A-Z]+\">redirected<\/a>})
      end
    end

    describe 'unsuccessful' do
      before :each do
        allow(SecureRandom).to receive(:uuid).and_return(nil)
      end

      subject do
        VCR.use_cassette('go_cardless redirect flow request failure') do
          get api_go_cardless_path(page, amount: 5, currency: 'EUR')
        end
      end

      it 'renders payment/donation_errors in the sumofus template' do
        subject
        expect(response).to render_template 'payment/donation_errors'
      end

      it 'assigns errors to be the relevant error message' do
        subject
        expect(assigns(:errors)).to eq(bad_request_errors)
      end
    end
  end

  describe 'after successful redirect flow' do
    let(:sdk_params) do
      {
        params: {
          amount: (gbp_amount * 100).to_i,
          currency: 'GBP',
          links: {
            mandate: mandate_id # a_string_matching(/\AMD[0-9A-Z]+\z/)
          },
          metadata: {
            customer_id: customer_id # a_string_matching(/\ACU[0-9A-Z]+\z/)
          }
        }
      }
    end

    let(:redirect_flow_id) { 'RE00004631S7XT20JATGRP6QQ8VZEHRZ' }
    let(:creditor_id)      { 'CR000045KKQEY8' }
    let(:mandate_id)       { 'MD0000PSV8N7FR' }
    let(:customer_id)      { 'CU0000RR39FMVB' }
    let(:customer_bank_account_id) { 'BA0000P8MREF5F' }

    let(:email) { 'test@example.com' }
    let(:payment_id_regexp) { /^PM[0-9A-Z]+/ }
    let(:subscription_id_regexp) { /^SB[0-9A-Z]+/ }

    let(:base_params) do
      {
        amount: usd_amount.to_s,
        currency: 'USD',
        provider: 'GC',
        recurring: 'false',
        redirect_flow_id: redirect_flow_id,
        user: {
          name: 'Bernie Sanders',
          email: 'test@example.com',
          postal: '11225',
          address1: '25 Elm Drive',
          akid: '123.456.789',
          source: 'fb',
          country: 'US',
          action_registered_voter: '1',
          form_id: '127'
        }
      }
    end

    let(:completed_flow) do
      GoCardlessPro::Resources::RedirectFlow.new('id' => redirect_flow_id,
                                                 'description' => nil,
                                                 'session_token' => 'iamatoken',
                                                 'scheme' => nil,
                                                 'success_redirect_url' => 'http://localhost:3000/api/go_cardless/payment_complete?amount=10&user%5Bform_id%5D=127&user%5Bemail%5D=nealjmd%40gmail.com&user%5Bname%5D=Neal+Donnelly&user%5Bcountry%5D=US&user%5Bpostal%5D=01060&currency=USD&recurring=false&provider=GC',
                                                 'created_at' => '2016-04-11T19:15:07.713Z',
                                                 'links' => {
                                                   'creditor' => creditor_id,
                                                   'mandate'  => mandate_id,
                                                   'customer' => customer_id,
                                                   'customer_bank_account' => customer_bank_account_id
                                                 })
    end

    before :each do
      allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:complete).and_return(completed_flow)
    end

    context 'successful' do
      shared_examples 'donation action' do
        it 'creates a PaymentMethod record with relevant data and associations' do
          expect { subject }.to change { Payment::GoCardless::PaymentMethod.count }.by(1)
          mandate = Payment::GoCardless::PaymentMethod.last
          expect(mandate.go_cardless_id).to eq mandate_id
          expect(mandate.scheme).to eq 'bacs'
          expect(mandate.next_possible_charge_date).not_to be_blank
          expect(mandate.customer).not_to be_blank
        end

        it 'creates an Action associated with the Page and Member' do
          expect { subject }.to change { Action.count }.by 1
          action = Action.last
          expect(action.page).to eq page
          expect(action.member).to eq (member.blank? ? Member.last : member)
        end

        it 'increments redis counters' do
          allow(Analytics::Page).to receive(:increment).and_return(7777)
          subject
          expect(Analytics::Page).to have_received(:increment).with(page.id, new_member: member.blank?)
        end

        it 'leaves a cookie with the member_id' do
          expect(cookies['member_id']).to eq nil
          subject

          # we can't access signed cookies in request specs, so check for hashed value
          expect(cookies['member_id']).not_to be_nil
          expect(cookies['member_id'].length).to be > 20
        end

        it 'increments action count on Page' do
          expect { subject }.to change { page.reload.action_count }.by(1)
        end

        it "redirects to the page's follow-up path" do
          subject
          expect(response.status).to redirect_to(follow_up_page_path(page))
        end

        it 'creates a Customer record with relevant data and associations' do
          expect { subject }.to change { Payment::GoCardless::Customer.count }.by(1)
          customer = Payment::GoCardless::Customer.last
          expect(customer.go_cardless_id).to eq customer_id
          expect(customer.member).not_to be_blank
        end
      end

      describe 'transaction' do
        let(:params) { base_params.merge(recurring: false) }
        let(:converted_money) { instance_double(Money, cents: 9001) }

        let(:donation_push_params) do
          {
            type: 'donation',
            payment_provider: 'go_cardless',
            meta: meta,
            params: {
              donationpage: {
                name: "#{page.slug}-donation",
                payment_account: 'GoCardless GBP'
              },
              order: hash_including(
                amount: gbp_amount.to_s,
                currency:       'GBP',
                card_num:       'DDEB',
                card_code:      '007',
                exp_date_month: '01',
                exp_date_year:  '99'
              ),
              user: hash_including(
                email: email,
                country: 'United States',
                postal: '11225',
                address1: '25 Elm Drive',
                first_name: 'Bernie',
                last_name: 'Sanders',
                akid: '123.456.789',
                source: 'fb',
                user_en: 1
              ),
              action: {
                source: 'fb',
                fields: hash_including(
                  action_registered_voter: '1',
                  action_mobile: 'tablet',
                  action_mandate_reference: 'OMAR-JMEKNM53MREX3',
                  action_bank_name: 'BARCLAYS BANK PLC',
                  action_account_number_ending: '11'
                )
              }
            }
          }
        end

        subject do
          VCR.use_cassette('go_cardless successful transaction') do
            get api_go_cardless_transaction_path(page.id), params
          end
        end

        shared_examples 'successful transaction' do
          let(:transaction_sdk_params) do
            {
              params: {
                amount: (gbp_amount * 100).to_i,
                currency: 'GBP',
                links: {
                  mandate: mandate_id # a_string_matching(/\AMD[0-9A-Z]+\z/)
                },
                metadata: {
                  customer_id: customer_id # a_string_matching(/\ACU[0-9A-Z]+\z/)
                },
                charge_date: /\d{4}\-\d{2}-\d{2}/
              }
            }
          end

          it 'sets the member status to donor' do
            subject
            member ||= Member.last # for examples with no pre-existing member
            expect(member.donor_status).to eq 'donor'
          end

          it 'passes the correct data to the GoCardless Payment SDK' do
            payment_service = instance_double(GoCardlessPro::Services::PaymentsService, create: double(id: 'asdf', charge_date: '2016-05-20'))
            allow_any_instance_of(GoCardlessPro::Client).to receive(:payments).and_return(payment_service)
            expect(payment_service).to receive(:create).with(transaction_sdk_params)
            subject
          end

          it 'posts donation action to queue with correct data' do
            allow(ChampaignQueue).to receive(:push)
            expect(ChampaignQueue).to receive(:push).with(donation_push_params)
            subject
          end

          it 'stores amount, currency, is_subscription, and transaction_id in form_data on the Action' do
            expect { subject }.to change { Action.count }.by(1)
            form_data = Action.last.form_data
            expect(form_data['is_subscription']).to be(false)
            expect(form_data['amount']).to eq(gbp_amount.to_s)
            expect(form_data['currency']).to eq('GBP')
            expect(form_data['transaction_id']).to eq(Payment::GoCardless::Transaction.last.go_cardless_id)
            expect(form_data).not_to have_key('subscription_id')
          end

          it 'creates a Transaction record with associations and data' do
            expect { subject }.to change { Payment::GoCardless::Transaction.count }.by 1
            payment = Payment::GoCardless::Transaction.last
            expect(payment.go_cardless_id).to match(payment_id_regexp)
            expect(payment.currency).to eq 'GBP'
            expect(payment.amount).to eq gbp_amount
            expect(payment.charge_date).not_to be_blank
            expect(payment.page).to eq page
            expect(payment.payment_method).not_to be_blank
            expect(payment.customer).not_to be_blank
            expect(payment.subscription_id).to be_nil
            expect(payment.aasm_state).to eq 'created'
          end
        end

        describe 'when Member exists' do
          let!(:member) { create :member, email: email }

          include_examples 'successful transaction'
          include_examples 'donation action'

          it "updates the Member's fields with any new data" do
            expect(member.email).to eq email
            expect(member.country).to be_blank
            expect(member.postal).to be_blank
            expect { subject }.not_to change { Member.count }
            member.reload
            expect(member.country).to eq 'US'
            expect(member.postal).to eq '11225'
          end

          it 'adds the first Customer to the Member' do
            expect { subject }.to change { member.reload.go_cardless_customers.size }.from(0).to(1)
          end

          it 'can add a second Customer to the Member' do
            create :payment_go_cardless_customer, member_id: member.id
            expect { subject }.to change { member.go_cardless_customers.size }.from(1).to(2)
          end

          it 'does not change donor_status to donor if its already recurring_donor' do
            member.recurring_donor!
            expect { subject }.not_to change { member.donor_status }.from('recurring_donor')
          end
        end

        describe 'when Member is new' do
          let(:member) { nil }

          include_examples 'successful transaction'
          include_examples 'donation action'

          it 'populates the Member’s fields with form data' do
            expect { subject }.to change { Member.count }.by(1)
            member = Member.last
            expect(member.country).to eq 'US'
            expect(member.postal).to eq '11225'
          end

          it 'associates the Member with a Customer' do
            expect { subject }.to change { Payment::GoCardless::Customer.count }.by(1)
            expect(Payment::GoCardless::Customer.last.member_id).to eq Member.last.id
          end
        end
      end

      describe 'subscription' do
        let(:params) { base_params.merge(recurring: true) }

        let(:donation_push_params) do
          {
            type: 'donation',
            payment_provider: 'go_cardless',
            meta: meta,
            params: {
              donationpage: {
                name: "#{page.slug}-donation",
                payment_account: 'GoCardless GBP'
              },
              order: {
                amount: gbp_amount.to_s,
                currency: 'GBP',
                recurring_id: subscription_id_regexp,
                card_num:       'DDEB',
                card_code:      '007',
                exp_date_month: '01',
                exp_date_year:  '99'
              },
              user: {
                email: email,
                country: 'United States',
                postal: '11225',
                address1: '25 Elm Drive',
                first_name: 'Bernie',
                last_name: 'Sanders',
                name: 'Bernie Sanders',
                akid: '123.456.789',
                source: 'fb',
                user_en: 1
              },
              action: {
                source: 'fb',
                fields: hash_including(
                  action_registered_voter: '1',
                  action_mobile: 'tablet',
                  action_mandate_reference: 'OMAR-JMEKNM53MREX3',
                  action_bank_name: 'BARCLAYS BANK PLC',
                  action_account_number_ending: '11',
                  action_express_donation: 0
                )
              }
            }
          }
        end

        subject do
          VCR.use_cassette('go_cardless successful subscription') do
            get api_go_cardless_transaction_path(page.id), params
          end
        end

        shared_examples 'successful subscription' do
          it 'passes the correct data to the GoCardless Payment SDK' do
            sdk_params[:params] = sdk_params[:params].merge(
              name: 'donation',
              interval_unit: 'monthly',
              start_date: /\d{4}\-\d{2}\-\d{2}/
            )

            subscriptions_service = instance_double(GoCardlessPro::Services::SubscriptionsService, create: double(id: 'asdf'))
            allow_any_instance_of(GoCardlessPro::Client).to receive(:subscriptions).and_return(subscriptions_service)
            expect(subscriptions_service).to receive(:create).with(sdk_params)
            subject
          end

          it 'posts donation action to queue with correct data' do
            allow(ChampaignQueue).to receive(:push)

            subject
            expect(ChampaignQueue).to have_received(:push).with(donation_push_params)
          end

          it 'stores amount, currency, is_subscription, and subscription_id in form_data on the Action' do
            expect { subject }.to change { Action.count }.by(1)
            form_data = Action.last.form_data
            expect(form_data['is_subscription']).to be true
            expect(form_data['amount']).to eq gbp_amount.to_s
            expect(form_data['currency']).to eq 'GBP'
            expect(form_data['subscription_id']).to eq Payment::GoCardless::Subscription.last.go_cardless_id
            expect(form_data).not_to have_key('transaction_id')
          end

          it 'does not yet create a transaction record' do
            expect { subject }.not_to change { Payment::GoCardless::Transaction.count }
          end

          it 'creates a Subscription record with associations and data' do
            expect { subject }.to change { Payment::GoCardless::Subscription.count }.by(1)
            subscription = Payment::GoCardless::Subscription.last
            expect(subscription.go_cardless_id).to match(subscription_id_regexp)
            expect(subscription.currency).to eq 'GBP'
            expect(subscription.amount).to eq gbp_amount
            expect(subscription.page).to eq page
            expect(subscription.payment_method).to be_a Payment::GoCardless::PaymentMethod
            expect(subscription.customer).to be_a Payment::GoCardless::Customer
            expect(subscription.action).to eq Action.last
            expect(subscription.aasm_state).to eq 'pending'
          end

          it 'sets the member status to recurring_donor' do
            subject
            member ||= Member.last # for examples with no pre-existing member
            expect(member.donor_status).to eq 'recurring_donor'
          end
        end

        describe 'when Member exists' do
          let!(:member) { create :member, email: email }

          include_examples 'successful subscription'
          include_examples 'donation action'

          it "updates the Member's fields with any new data" do
            expect(member.email).to eq email
            expect(member.country).to be_blank
            expect(member.postal).to be_blank
            expect { subject }.not_to change { Member.count }
            member.reload
            expect(member.country).to eq 'US'
            expect(member.postal).to eq '11225'
          end

          it 'adds the first customer to the member' do
            expect { subject }.to change { member.reload.go_cardless_customers.size }.from(0).to(1)
          end

          it 'can add a second customer to the member' do
            create :payment_go_cardless_customer, member_id: member.id
            expect { subject }.to change { member.go_cardless_customers.size }.from(1).to(2)
          end
        end

        describe 'when Member is new' do
          let(:member) { nil }

          include_examples 'successful subscription'
          include_examples 'donation action'

          it 'populates the Member’s fields with form data' do
            expect { subject }.to change { Member.count }.by 1
            member = Member.last
            expect(member.country).to eq 'US'
            expect(member.postal).to eq '11225'
          end

          it 'associates the Member with a Customer' do
            expect { subject }.to change { Payment::GoCardless::Customer.count }.by(1)
            expect(Payment::GoCardless::Customer.last.member_id).to eq Member.last.id
          end
        end
      end
    end

    context 'unsuccessful' do
      shared_examples 'correctly handles errors' do
        it 'does not create a PaymentMethod' do
          expect { subject }.not_to change { Payment::GoCardless::PaymentMethod.count }
        end

        it 'does not create a Transaction' do
          expect { subject }.not_to change { Payment::GoCardless::Transaction.count }
        end

        it 'does not create a Subscription' do
          expect { subject }.not_to change { Payment::GoCardless::Subscription.count }
        end

        it 'does not create an Action' do
          expect { subject }.not_to change { Action.count }
        end

        it 'does not create a Member' do
          expect { subject }.not_to change { Member.count }
        end

        it 'does not push to the queue' do
          allow(ChampaignQueue).to receive(:push)
          expect(ChampaignQueue).not_to receive(:push)
          subject
        end

        it 'does not leave a cookie' do
          expect(cookies['member_id']).to eq nil
          subject
          expect(cookies['member_id']).to eq nil
        end

        it 'does not increment redis counters' do
          allow(Analytics::Page).to receive(:increment).and_return(7777)
          subject
          expect(Analytics::Page).not_to have_received(:increment)
        end

        it 'does not change the action count on Page' do
          expect { subject }.not_to change { page.reload.action_count }
        end

        it 'assigns page to current page' do
          subject
          expect(assigns(:page)).to eq page
        end

        it 'renders payment/donation_errors' do
          subject
          expect(response).to render_template 'payment/donation_errors'
        end
      end

      shared_examples 'displays bad request errors' do
        it 'assigns errors to relevant errors' do
          subject
          expect(assigns(:errors)).to eq(bad_request_errors)
        end

        it 'assigns errors to relevant errors in the correct language' do
          page.update_attributes(language: create(:language, code: :fr))
          french_message = 'Notre équipe technique a été notifiée de ce problème. Veuillez revérifier vos informations ou choisir une autre méthode de paiement.'
          subject
          expect(assigns(:errors)).to eq([bad_request_errors[0].merge(message: french_message)])
        end
      end

      shared_examples 'displays bad id errors' do
        it 'assigns errors to relevant errors' do
          subject
          expect(assigns(:errors)).to eq([bad_request_errors.first.merge(code: 404)])
        end
      end

      describe 'mandate retrieval' do
        before :each do
          # to make the mandate get fail
          allow_any_instance_of(GoCardlessPro::Resources::RedirectFlow).to receive(:links).and_return(
            double(customer: 'CU00000000', mandate: 'MA000000')
          )
        end

        let(:params) { base_params.merge(recurring: false) }

        subject do
          VCR.use_cassette('go_cardless unsuccessful mandate retrieval') do
            get api_go_cardless_transaction_path(page.id), params
          end
        end

        include_examples 'correctly handles errors'
        include_examples 'displays bad id errors'
      end

      describe 'redirect flow completion' do
        before :each do
          allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:complete).and_call_original
        end

        let(:params) { base_params.merge(recurring: false, redirect_flow_id: 'RE000033300000') }

        subject do
          VCR.use_cassette('go_cardless unsuccessful flow completion') do
            get api_go_cardless_transaction_path(page.id), params
          end
        end

        include_examples 'correctly handles errors'
        include_examples 'displays bad id errors'
      end

      describe 'transaction' do
        before :each do
          # to make the creation fail
          allow_any_instance_of(GoCardlessPro::Resources::Mandate).to receive(:id).and_return(nil)
        end

        let(:params) { base_params.merge(recurring: false) }

        subject do
          VCR.use_cassette('go_cardless unsuccessful transaction') do
            get api_go_cardless_transaction_path(page.id), params
          end
        end

        include_examples 'correctly handles errors'
        include_examples 'displays bad request errors'
      end

      describe 'subscription' do
        before :each do
          # to make the creation fail
          allow_any_instance_of(GoCardlessPro::Resources::Mandate).to receive(:id).and_return(nil)
        end

        let(:params) { base_params.merge(recurring: true) }

        subject do
          VCR.use_cassette('go_cardless unsuccessful subscription') do
            get api_go_cardless_transaction_path(page.id), params
          end
        end

        include_examples 'correctly handles errors'
        include_examples 'displays bad request errors'
      end
    end
  end
end
