# frozen_string_literal: true

require 'rails_helper'

describe ForgetMember do
  let(:member_attributes) do
    {
      more: { 'foo' => 'bar' },
      email: 'foo@example.com',
      actionkit_user_id: '123',
      address1: 'one',
      address2: 'two',
      postal: '1234',
      first_name: 'Foo',
      last_name: 'Bar'
    }
  end

  let(:member) { create(:member, member_attributes) }
  let!(:action) { create(:action, member: member, form_data: { name: 'Boo' }) }
  let!(:authentication) { create(:member_authentication, member: member) }
  let(:braintree_customer) { create(:payment_braintree_customer, email: 'foo@example.com', member: member) }
  let!(:payment_method) {
    create(:payment_braintree_payment_method,
           customer: braintree_customer,
           email: 'foo@example.com')
  }

  it 'anonymises member' do
    expect {
      ForgetMember.forget(member)
    }.to change { member.reload.attributes }
      .from(hash_including(member_attributes.stringify_keys))
      .to(hash_including(
        {
          more: nil,
          email: nil,
          actionkit_user_id: nil,
          address1: nil,
          address2: nil,
          postal: nil,
          first_name: nil,
          last_name: nil
        }.stringify_keys
      ))
  end

  it 'anonymises actions' do
    expect {
      ForgetMember.forget(member)
    }.to change { action.reload.form_data }
      .from('name' => 'Boo')
      .to(nil)
  end

  it 'destroys authentication' do
    expect {
      ForgetMember.forget(member)
    }.to change { member.reload.authentication }
      .from(authentication)
      .to(nil)
  end

  it 'anonymises braintree customer' do
    expect {
      ForgetMember.forget(member)
    }.to change { member.reload.braintree_customer.attributes }
      .from(hash_including('email' => 'foo@example.com'))
      .to(hash_including('email' => nil))
  end

  it 'anonymises braintree payment method' do
    expect {
      ForgetMember.forget(member)
    }.to change { payment_method.reload.email }
      .from('foo@example.com')
      .to(nil)
  end
end
