require 'rails_helper'

describe "GoCardless API" do
  let(:usd_amount) { 9.99 }
  let(:gbp_amount) { 11.55 }
  before :each do
    allow_any_instance_of(Money).to receive(:exchange_to).and_return(
      instance_double(Money, cents: (gbp_amount*100).to_i)
    )
  end

  describe "redirect flow" do

    let(:page) { create :page }

    subject do
      VCR.use_cassette("go_cardless redirect flow request success") do
        get api_go_cardless_path(page)
      end
    end

    it "redirects to a GoCardless-hosted page" do
      subject
      expect(response.status).to be 302
      expect(response.body).to match /You are being <a href=\"https:\/\/pay-sandbox.gocardless.com\/flow\/RE[0-9A-Z]+\">redirected<\/a>/
    end

  end

  describe "GoCardless posting back from a redirect flow with not having completed the form" do

    let(:go_cardless_params) do
      {
        session_token: 'iamatoken',
        redirect_flow_id: 'RE000044PXTW1DMX04G13KP3NNQDD1TA'
      }
    end

    subject do
      VCR.use_cassette("go_cardless redirect_flow_post_back_payment") do
        get api_go_cardless_transaction_path, go_cardless_params
      end
    end

    it "responds with an error because customer has not filled the payment form" do
      expect { subject }.to raise_error(GoCardlessPro::InvalidStateError)
    end
  end

  describe 'after successful redirect flow' do

    let(:donation_push_params) do
      {
        # This is just copied from BT and needs to be changed
        type: "donation",
        params: {
          donationpage: {
            name: page.slug,
            payment_account: "GoCardless" # check this
          },
          order: {
            amount: gbp_amount.to_s,
            currency: "GBP"
          },
          user: {
            email: email,
            country: "United States",
            postal: "11225",
            address1: '25 Elm Drive',
            first_name: 'Bernie',
            last_name: 'Sanders',
            akid: '1234.5678.9910',
            source: 'fb',
            user_en: 1
          },
          action: {
            source: 'fb',
            fields: {
              recurring_id: 1,
              recurrence_number: 0,
              exp_date: "1220"
            }
          }
        }
      }
    end
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
    let(:redirect_flow_id) { "RE00004631S7XT20JATGRP6QQ8VZEHRZ" }
    let(:creditor_id)      { "CR000045KKQEY8" }
    let(:mandate_id)       { "MD0000PSV8N7FR" }
    let(:customer_id)      { "CU0000RR39FMVB" }
    let(:customer_bank_account_id) { "BA0000P8MREF5F" }

    let(:page) { create :page }
    let(:email) { "nealjmd@gmail.com" }

    let(:base_params) do
      {
        amount: usd_amount.to_s,
        currency: "USD",
        provider: "GC",
        recurring: "false",
        redirect_flow_id: redirect_flow_id,
        page_id: page.id,
        user: {
          country: "US",
          email: email,
          form_id: "127",
          name: "Neal Donnelly",
          postal: "01060"
        }
      }
    end

    let(:completed_flow) do
      GoCardlessPro::Resources::RedirectFlow.new({
        "id" => redirect_flow_id,
        "description" => nil,
        "session_token" => "iamatoken",
        "scheme" => nil,
        "success_redirect_url" => "http://localhost:3000/api/go_cardless/payment_complete?amount=10&user%5Bform_id%5D=127&user%5Bemail%5D=nealjmd%40gmail.com&user%5Bname%5D=Neal+Donnelly&user%5Bcountry%5D=US&user%5Bpostal%5D=01060&currency=USD&recurring=false&provider=GC",
        "created_at" => "2016-04-11T19:15:07.713Z",
        "links" => {
          "creditor" => creditor_id,
          "mandate"  => mandate_id,
          "customer" => customer_id,
          "customer_bank_account" => customer_bank_account_id
        }
      })
    end

    before :each do
      allow_any_instance_of(GoCardlessPro::Services::RedirectFlowsService).to receive(:complete).and_return(completed_flow)
    end

    shared_examples 'donation action' do
      it 'creates a PaymentMethod record that stores the mandate id' do
        expect{ subject }.to change{ Payment::GoCardless::PaymentMethod.count }.by 1
        mandate = Payment::GoCardless::PaymentMethod.last
        expect(mandate.go_cardless_id).to eq mandate_id
      end

      it 'creates an Action associated with the Page and Member' do
        expect{ subject }.to change{ Action.count }.by 1
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
        expect(cookies['member_id']).not_to eq nil
        expect(cookies['member_id'].length).to be > 20
      end

      it 'increments action count on Page' do
        expect{ subject }.to change{ page.reload.action_count }.by 1
      end

      it "redirects to the page's follow-up path" do
        subject
        expect(response.status).to redirect_to(follow_up_page_path(page))
      end
    end

    describe 'transaction' do

      let(:params) { base_params.merge(recurring: false) }
      let(:converted_money) { instance_double(Money, cents: 9001) }

      subject do
        VCR.use_cassette('go_cardless successful transaction') do
          get api_go_cardless_transaction_path, params
        end
      end

      shared_examples 'successful transaction' do
        it 'passes the correct data to the GoCardless Payment SDK' do
          payment_service = instance_double(GoCardlessPro::Services::PaymentsService, create: double(id: 'asdf'))
          allow_any_instance_of(GoCardlessPro::Client).to receive(:payments).and_return(payment_service)
          expect(payment_service).to receive(:create).with(sdk_params)
          subject
        end

        it 'posts donation action to queue with correct data' do
          allow( ChampaignQueue ).to receive(:push)
          # make any changes to donation_push_params here
          expect( ChampaignQueue ).to receive(:push).with(donation_push_params)
          subject
        end

        it 'stores amount, currency, is_subscription, and transaction_id in form_data on the Action' do
          expect{ subject }.to change{ Action.count }.by 1
          form_data = Action.last.form_data
          expect(form_data['is_subscription']).to eq false
          expect(form_data['amount']).to eq gbp_amount.to_s
          expect(form_data['currency']).to eq 'GBP'
          expect(form_data['transaction_id']).to eq Payment::GoCardless::Transaction.last.go_cardless_id
          
          expect(form_data).not_to have_key('subscription_id')
        end

        it 'creates a Transaction record associated with the Page' do
          expect{ subject }.to change{ Payment::GoCardless::Transaction.count }.by 1
          payment = Payment::GoCardless::Transaction.last
          expect(payment.go_cardless_id).to match(/^PM[0-9A-Z]+/)
          expect(payment.currency).to eq 'GBP'
          expect(payment.amount).to eq gbp_amount
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
          expect{ subject }.not_to change{ Member.count }
          member.reload
          expect(member.country).to eq "US"
          expect(member.postal).to eq "01060"
        end
      end

      describe 'when Member is new' do
        let(:member) { nil }

        include_examples 'successful transaction'
        include_examples 'donation action'

        it "populates the Member’s fields with form data" do
          expect{ subject }.to change{ Member.count }.by 1
          member = Member.last
          expect(member.country).to eq "US"
          expect(member.postal).to eq "01060"
        end
      end
    end

    describe 'subscription' do

      let(:params) { base_params.merge(recurring: true) }

      subject do
        VCR.use_cassette('go_cardless successful subscription') do
          get api_go_cardless_transaction_path, params
        end
      end

      shared_examples 'successful subscription' do
        it 'passes the correct data to the GoCardless Payment SDK' do
          sdk_params[:params] = sdk_params[:params].merge(
            name: "donation",
            interval_unit: "monthly",
            day_of_month: "1"
          )
          subscriptions_service = instance_double(GoCardlessPro::Services::SubscriptionsService, create: double(id: 'asdf'))
          allow_any_instance_of(GoCardlessPro::Client).to receive(:subscriptions).and_return(subscriptions_service)
          expect(subscriptions_service).to receive(:create).with(sdk_params)
          subject
        end

        it 'posts donation action to queue with correct data' do
          allow( ChampaignQueue ).to receive(:push)
          # make any changes to donation_push_params here
          expect( ChampaignQueue ).to receive(:push).with(donation_push_params)
          subject
        end

        it 'stores amount, currency, is_subscription, and subscription_id in form_data on the Action' do
          expect{ subject }.to change{ Action.count }.by 1
          form_data = Action.last.form_data
          expect(form_data['is_subscription']).to eq true
          expect(form_data['amount']).to eq gbp_amount.to_s
          expect(form_data['currency']).to eq 'GBP'
          expect(form_data['subscription_id']).to eq Payment::GoCardless::Subscription.last.go_cardless_id
          expect(form_data).not_to have_key('transaction_id')
        end

        it 'does not yet create a transaction record' do
          expect{ subject }.not_to change{ Payment::GoCardless::Transaction.count }
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
          expect{ subject }.not_to change{ Member.count }
          member.reload
          expect(member.country).to eq "US"
          expect(member.postal).to eq "01060"
        end
      end

      describe 'when Member is new' do
        let(:member) { nil }

        include_examples 'successful subscription'
        include_examples 'donation action'

        it "populates the Member’s fields with form data" do
          expect{ subject }.to change{ Member.count }.by 1
          member = Member.last
          expect(member.country).to eq "US"
          expect(member.postal).to eq "01060"
        end
      end
    end

  end

end
