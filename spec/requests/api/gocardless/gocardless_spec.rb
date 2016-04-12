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

end