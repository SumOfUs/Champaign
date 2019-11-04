# frozen_string_literal: true

shared_examples 'transaction and subscription' do |method|
  let(:gc_service_class) do
    if method == :make_subscription
      GoCardlessPro::Services::SubscriptionsService
    else
      GoCardlessPro::Services::PaymentsService
    end
  end

  describe 'call signature' do
    %i[amount currency user page_id redirect_flow_id session_token].each do |keyword|
      it "requires a #{keyword}" do
        expect do
          required_options.delete(keyword)
          described_class.send(method, **required_options)
        end.to raise_error(ArgumentError, "missing keyword: #{keyword}")
      end
    end
  end

  describe 'calling the GC SDK' do
    it 'completes the redirect flow with the right params' do
      expect_any_instance_of(
        GoCardlessPro::Services::RedirectFlowsService
      ).to receive(:complete).with('RE00000', params: { session_token: required_options[:session_token] })
      subject
    end

    it 'fetches the redirect flow when the flow has already been completed' do
      allow_any_instance_of(
        GoCardlessPro::Services::RedirectFlowsService
      ).to receive(:complete).and_raise(
        GoCardlessPro::InvalidStateError.new('message' => 'Flow already completed.')
      )
      expect_any_instance_of(
        GoCardlessPro::Services::RedirectFlowsService
      ).to receive(:get).with('RE00000')
      subject
    end
  end

  describe 'currency' do
    let(:amount_in_usd_cents) { (amount_in_dollars * 100).to_i }

    it 'converts currency to GBP if scheme is BACS' do
      allow(mandate).to receive(:scheme).and_return('bacs')
      expect(PaymentProcessor::Currency).to receive(:convert).with(amount_in_usd_cents, 'GBP', 'USD')
      subject
    end

    # Temporarily commented out until Sweden currency is added to GoCardless account
    # it 'converts currency to SEK if scheme is autogiro' do
    #   allow(mandate).to receive(:scheme).and_return('autogiro')
    #   expect(PaymentProcessor::Currency).to receive(:convert).with(amount_in_usd_cents, 'SEK', 'USD')
    #   subject
    # end

    it 'converts currency to EUR if scheme is SEPA' do
      allow(mandate).to receive(:scheme).and_return('sepa')
      expect(PaymentProcessor::Currency).to receive(:convert).with(amount_in_usd_cents, 'EUR', 'USD')
      subject
    end
  end

  describe 'error_container' do
    it 'returns nil on success' do
      builder = subject
      expect(builder.error_container).to eq nil
    end

    it 'returns the GoCardless error when unsuccessful' do
      allow_any_instance_of(gc_service_class).to receive(:create).and_raise(gc_error)
      builder = subject
      expect(builder.error_container).to eq(gc_error)
    end
  end

  describe 'action' do
    it 'returns the Action object when successful' do
      builder = subject
      expect(builder.action).to eq action
    end

    it 'returns nil when unsuccessful' do
      allow_any_instance_of(gc_service_class).to receive(:create).and_raise(gc_error)
      builder = subject
      expect(builder.action).to eq nil
    end
  end

  describe 'bookkeeping' do
    it 'delegates to Payment::GoCardless.write_customer' do
      expect(Payment::GoCardless).to receive(:write_customer).with('CU00000', action.member_id)
      subject
    end

    it 'delegates to Payment::GoCardless.write_mandate' do
      expect(Payment::GoCardless).to receive(:write_mandate).with(
        'MA00000', 'sepa', mandate.next_possible_charge_date, local_customer.id
      )
      subject
    end
  end
end
