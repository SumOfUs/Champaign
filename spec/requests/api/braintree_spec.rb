require 'rails_helper'

describe "Braintree API" do

  let(:page) { create(:page, title: 'Cash rules everything around me') }
  let(:form) { create(:form) }

  before :each do
    allow(ChampaignQueue).to receive(:push)
  end

  describe 'making a transaction' do
    describe 'success' do

      let(:basic_params) do
        {
          currency: 'EUR',
          payment_method_nonce: 'fake-valid-nonce',
          amount: 123.05,
          recurring: false
        }
      end
      let(:user_params) do
        {
          form_id: form.id, 
          name: "Joe Ferris", 
          email: "joe.ferris@sumofus.org",
          postal: "11225",
          address1: '25 Elm Drive',
          country: "US"
        }
      end

      context 'Member exists' do

        let!(:member) { create :member, email: user_params[:email], postal: nil }

        context 'BraintreeCustomer exists' do

          let!(:customer) { create :payment_braintree_customer, member: member }

          context 'with basic params' do

            let(:params) { basic_params.merge(user: user_params) }
            subject do
              VCR.use_cassette("transaction success") do
                post api_braintree_transaction_path(page.id), params
              end
            end

            it "creates an Action associated with the Page and Member" do
              expect{ subject }.to change{ Action.count }.by 1
              expect(Action.last.page).to eq page
              expect(Action.last.member).to eq member
            end

            it "stores amount, currency, and transaction_id in form_data on the Action" do
              expect{ subject }.to change{ Action.count }.by 1
              form_data = Action.last.form_data
              expect(form_data['amount']).to eq '123.05'
              expect(form_data['currency']).to eq 'EUR'
              expect(form_data['transaction_id']).to eq Payment::BraintreeTransaction.last.transaction_id
            end

            it "creates a Transaction associated with the page" do
              expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
              expect(Payment::BraintreeTransaction.last.page).to eq page
            end

            it "updates Payment::BraintreeCustomer including last four for credit card" do
              previous_last_4 = customer.card_last_4
              expect{ subject }.to change{ Payment::BraintreeCustomer.count }.by 0
              expect( customer.reload.card_last_4 ).not_to eq previous_last_4
            end

            it "posts donation action to queue with key data" do
              subject
              expect( ChampaignQueue ).to have_received(:push).with({
                type: "donation",
                params: {
                  donationpage: {
                    name: "cash-rules-everything-around-me-donation",
                    payment_account: "Default Import Stub"
                  },
                  order: {
                    amount: "123.05",
                    card_num: "1881",
                    card_code: "007",
                    exp_date_month: "12",
                    exp_date_year: "2020",
                    currency: "EUR"
                  },
                  user: {
                    # Double check - it's only sending email and country
                    email:"joe.ferris@sumofus.org",
                    country:"US"
                  }
                }
              })
            end

            it "increments action count on page" do
              expect{ subject }.to change{ page.reload.action_count }.by 1
            end

            it "passes the params to braintree" do
              allow(Braintree::Transaction).to receive(:sale).and_call_original
              subject
              expect(Braintree::Transaction).to have_received(:sale).with({
                amount: 123.05,
                payment_method_nonce: "fake-valid-nonce",
                merchant_account_id: "EUR",
                options: {
                  submit_for_settlement: true,
                  store_in_vault_on_success: false
                },
                customer: {
                  first_name: "Joe",
                  last_name: "Ferris",
                  email: "joe.ferris@sumofus.org"
                },
                billing: {
                  first_name: "Joe",
                  last_name: "Ferris",
                  street_address: "25 Elm Drive",
                  postal_code: '11225',
                  country_code_alpha2: 'US'
                },
                customer_id: customer.customer_id
              })
            end

            it "leaves a cookie with the member_id" do
              expect(cookies['member_id']).to eq nil
              subject

              # we can't access signed cookies in request specs, so check for hashed value
              expect(cookies['member_id']).not_to eq nil
              expect(cookies['member_id'].length).to be > 20
            end

            it "updates the Member’s fields with any new data" do
              expect(member.first_name).not_to eq 'Joe'
              expect(member.last_name).not_to eq 'Ferris'
              expect(member.postal).to eq nil
              expect{ subject }.to change{ Member.count }.by 0
              member.reload
              expect(member.first_name).to eq 'Joe'
              expect(member.last_name).to eq 'Ferris'
              expect(member.postal).to eq '11225'
            end
          end

          context 'with different params' do

            it 'passes PYPL'
          end
        end

        context 'BraintreeCustomer is new' do

        end
      end

      context 'Member is new' do
        context 'BraintreeCustomer is new' do

        end
      end
    end
  end
end


