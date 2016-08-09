require "rails_helper"

describe "subscriptions/index" do
  let(:transaction) { double(id: 'abc', status: 'authorized', created_at: Time.now, amount: BigDecimal.new(2.00, 5)) }
  before do
    assign :subscriptions, [
      double(id: 'xyz', billing_day_of_month: 1, created_at: Time.now, amount: BigDecimal.new(2.00, 5), transactions: [transaction])
    ]
  end

  subject{ render(template: "api/stateless/braintree/subscriptions/index.json.jbuilder") }

  it 'displays subscriptions' do
    subject
    expect(JSON.parse(rendered).first).to include({
      id: 'xyz',
      billing_day_of_month: 1,
      created_at: /^\d{4}-\d{2}-\d{2}/,
      amount: '2.0',
      transactions: [{
        id: 'abc',
        status: 'authorized',
        created_at: /^\d{4}-\d{2}-\d{2}/,
        amount: '2.0'
      }]
    }.deep_stringify_keys)
  end
end

