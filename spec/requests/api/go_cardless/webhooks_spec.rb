require 'rails_helper'
"eac5bd1740841f39111333d572f525f1f03cdacc04b0ecc43e17a3da4787a011"
{"events"=>
 [{"id"=>"EVTEST6RQPRR7D",
   "created_at"=>"2016-04-20T10:32:34.696Z",
   "resource_type"=>"subscriptions",
   "action"=>"payment_created",
   "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
   "details"=>
 {"origin"=>"gocardless",
  "cause"=>"payment_created",
  "description"=>"Payment created by a subscription."},
  "metadata"=>{}}]
}

describe "subscriptions" do
  let(:events) do
    {"events"=>
     [{"id"=>"EVTEST6RQPRR7D",
       "created_at"=>"2016-04-20T10:32:34.696Z",
       "resource_type"=>"subscriptions",
       "action"=>"payment_created",
       "links"=>{"payment"=>"payment_ID_123", "subscription"=>"index_ID_123"},
       "details"=>
     {"origin"=>"gocardless",
      "cause"=>"payment_created",
      "description"=>"Payment created by a subscription."},
      "metadata"=>{} }
     ]
    }.to_json
  end

  let!(:subscription) { create :payment_go_cardless_subscription, go_cardless_id: 'index_ID_123' }

  describe "with valid signature" do
    it 'processes events' do
      headers = {
        'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json',
        'HTTP_WEBHOOK_SIGNATURE' => 'eac5bd1740841f39111333d572f525f1f03cdacc04b0ecc43e17a3da4787a011'
      }

      post('/api/go_cardless/webhook', events, headers)
      expect(subscription.reload.aasm_state).to eq('active')
    end
  end

  describe "with invalid signature" do
      headers = {
        'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json',
        'HTTP_WEBHOOK_SIGNATURE' => 'bad_signature'
      }

    it 'responds with 498' do
      headers = {
        'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json',
        'HTTP_WEBHOOK_SIGNATURE' => 'not_valid'
      }

      post('/api/go_cardless/webhook', events, headers)

      expect(response.status).to eq(427)
    end
  end

end




