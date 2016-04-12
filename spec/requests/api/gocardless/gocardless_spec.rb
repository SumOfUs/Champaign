require 'rails_helper'

describe "GoCardless API" do

  describe "triggering a redirect flow" do

    subject do
      VCR.use_cassette("gocardless redirect flow request success") do
        get api_go_cardless_start_flow_path
      end
    end

    it "redirects to a GoCardless hosted a redirect flow page" do
      subject
      expect(response.status).to be 302
      expect(response.body).to include "You are being <a href=\"https://pay-sandbox.gocardless.com/flow/RE000044PXTW1DMX04G13KP3NNQDD1TA\">redirected</a>"
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
      VCR.use_cassette("gocardless redirect_flow_post_back_payment") do
        get api_go_cardless_payment_complete_path, go_cardless_params
      end
    end

    it "responds with an error because customer has not filled the payment form" do
      expect { subject }.to raise_error(GoCardlessPro::InvalidStateError)
    end
  end

  describe 'after successful redirect flow' do

    let(:params) do
      {
        amount: "10",
        currency: "USD",
        provider: "GC",
        recurring: "false",
        redirect_flow_id: "RE00004631S7XT20JATGRP6QQ8VZEHRZ",
        user: {
          country: "US",
          email: "nealjmd@gmail.com",
          form_id: "127",
          name: "Neal Donnelly",
          postal: "01060"
        }
      }
    end
    let(:completed_flow) do
      GoCardlessPro::Resources::RedirectFlow.new({
        "id" => "RE00004631S7XT20JATGRP6QQ8VZEHRZ",
        "description" => nil,
        "session_token" => "iamatoken",
        "scheme" => nil,
        "success_redirect_url" => "http://localhost:3000/api/go_cardless/payment_complete?amount=10&user%5Bform_id%5D=127&user%5Bemail%5D=nealjmd%40gmail.com&user%5Bname%5D=Neal+Donnelly&user%5Bcountry%5D=US&user%5Bpostal%5D=01060&currency=USD&recurring=false&provider=GC",
        "created_at" => "2016-04-11T19:15:07.713Z",
        "links" => {
          "creditor" => "CR000045KKQEY8",
          "mandate" => "MD0000PSV8N7FR",
          "customer" => "CU0000RR39FMVB",
          "customer_bank_account" => "BA0000P8MREF5F"
        }
      })
    end
    let(:redirect_flows) { double(complete: completed_flow )}

    before :each do
      allow_any_instance_of(GoCardlessPro::Client).to receive(:redirect_flows).and_return(redirect_flows)
    end

    describe 'transaction' do

      describe 'successfully' do
        subject do
          VCR.use_cassette('gocardless successful transaction') do
            get api_go_cardless_payment_complete_path, params
          end
        end

        it 'creates a transaction record' do
          expect{ subject }.to change{ Payment::GoCardless::Transaction.count }.by 1
        end
      end
    end

  end

end