require 'rails_helper'

describe ManageBraintreeDonation do
  # Because ManageBraintreeDonation extends ManageAction, we won't re-test any of the logic that we didn't overwrite.
  # So the only thing to test here is that the parameter dictionary is built correctly and sent to the queue
  # correctly

  let(:page) { create(:page) }
  let(:data) { { email: 'bob@example.com', page_id: page.id } }

  let(:full_donation_options) {
    {
        donationpage: {
            name: 'donation',
            payment_account: 'Default Import Stub'
        },
        order: {
            amount: '1',
            card_num: '4111111111111111',
            card_code: '007',
            exp_date_month: '01',
            exp_date_year: '2016'
        },
        user: {
            email: data[:email],
            country: 'United States',
        },
        page_id: page.id
    }
  }

  let(:expected_queue_message) {
    {
        type: 'donation',
        params: full_donation_options
    }
  }

  before do
    allow(ChampaignQueue).to receive(:push)
  end

  it 'creates the right kind of request' do
    expect(ChampaignQueue).to receive(:push).with(expected_queue_message)
    ManageBraintreeDonation.create(full_donation_options)
  end
end
