# frozen_string_literal: true

require 'rails_helper'

describe Api::HMACSignatureValidator do
  subject { described_class.new(secret: secret, signature: signature, data: data) }

  let(:secret) { 'hotpotato!' }
  let(:signature) { '4b3d28161c077769c221ffabdc05850e68923e4659f212f0ae43d3e6f85c313c' }
  let(:data) do
    '"{\"controller\":\"api/member_services\",\"action\":\"cancel_recurring_donation\",\
"provider\":\"braintree\",\"id\":\"BraintreeWoohoo\"}"'
  end

  context 'with correct secret' do
    it 'validates signature' do
      expect(subject.valid?).to be(true)
    end
  end

  context 'with incorrect secret' do
    let(:secret) { 'coldpotato!' }

    it 'does not validate signature' do
      expect(subject.valid?).to_not be(true)
    end
  end
end
