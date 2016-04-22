require 'rails_helper'

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

  let!(:page)         { create(:page) }
  let!(:member)       { create(:member) }
  let!(:action)       { create(:action, member: member, page: page, donation: true, form_data: {amount: 100, currency: 'GBP', payment_provider: 'go_cardless'}) }
  let!(:subscription) { create(:payment_go_cardless_subscription, go_cardless_id: 'index_ID_123', action: action, amount: 100) }

  describe "with valid signature" do
    let(:headers) do
      {
        'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json',
        'HTTP_WEBHOOK_SIGNATURE' => 'eac5bd1740841f39111333d572f525f1f03cdacc04b0ecc43e17a3da4787a011'
      }
    end

    it 'processes events' do
      post('/api/go_cardless/webhook', events, headers)
      expect(subscription.reload.aasm_state).to eq('active')
    end

    context 'with payment_created event' do
      before do
        allow(ChampaignQueue).to receive(:push)
        post('/api/go_cardless/webhook', events, headers)
      end

      it 'updates action with recurrence number' do
        expect(subscription.action.reload.form_data).to include( 'recurrence_number' => 1 )
      end

      describe 'transaction' do
        subject { Payment::GoCardless::Transaction.first }

        it 'has correct attributes' do
          expect(
            subject.attributes.symbolize_keys
          ).to include({
            go_cardless_id: 'payment_ID_123',
            page_id: page.id,
            amount: 100
          })
        end

        it 'is confirmed' do
         expect(
            subject.confirmed?
          ).to be(true)
        end
      end

      describe "Posting to queue" do
        it 'posts to queue' do
          expect( ChampaignQueue ).to have_received(:push).with(
            a_hash_including(
              params: a_hash_including({ order: { amount: 100, currency: 'GBP'}})
            )
          )
        end
      end
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
