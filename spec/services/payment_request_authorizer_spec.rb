# frozen_string_literal: true

require 'rails_helper'

describe PaymentRequestAuthorizer do
  include Rails.application.routes.url_helpers

  let(:page) { create(:page, publish_status: 'published') }

  # create single member instance
  let(:member) do
    @member ||= create(:member)
  end

  let(:customer) do
    @customer ||= begin
      attrs = FactoryBot.attributes_for(:payment_braintree_customer, member_id: member.id, email: member.email)
      Payment::Braintree::Customer.create(attrs)
    end
  end

  let(:random_customer) do
    attrs = FactoryBot.attributes_for(:payment_braintree_customer)
    Payment::Braintree::Customer.create(attrs)
  end

  let(:transaction) { Payment::Braintree::Transaction.last }

  # rubocop:disable LineLength
  let(:valid_data) do
    { recaptcha: '03AOLTBLTx8PMg5ysKEN5nLmhzDad2lIHsf7rSVaDogDrChLL6hprN3nLFMjpvtr0FWewUDezV_SgV-YfUSU2yOyClXx6xaI4OxRsELoi4626iU31B4pdx3pCtcpNNBA8u1yB7IJxtpLM-E7_vdy7IfvS0YEB1758VVpxiJEbGTLmLb111SjTkFBWuhZ3XyrHFca-22uLzKpawc8RQ1-j57ZR3SMel4DCkNzveSWjYYH381z_MAY7Ev5Q7tK6_iEqrqUsgSt1wF-xtht5fLmjKXYkknPN3SB1_32mRl9BBuMzfIl6wO-GUnWhKbzEpsSlSqbEhljS_38GxViA3gC1eu5cOQWhKde56-EKYOG1JaTb8QiyamDoKKetITV8yWy8ZlmcspgD0Gv9B',
      action: 'donate/83',
      email: 'test@example.com',
      params: { page: '1' } }
  end
  # rubocop:enable LineLength
  let(:invalid_data) do
    { token: nil, action: nil }
  end

  let(:empty_data) do
    { recaptcha: nil, action: nil, email: nil, params: {} }
  end

  describe '.valid?' do
    context 'empty data' do
      subject { PaymentRequestAuthorizer.new(empty_data) }

      it 'should validates presence of recaptcha, action and email' do
        subject.valid?
        expect(subject.errors.size).to eql 4
        expect(subject.errors.full_messages).to include(
          "Email can't be blank",
          "Recaptcha can't be blank",
          "Action can't be blank",
          'Invalid request'
        )
      end
    end

    context 'Valid captcha' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
      end

      it 'should allow new user' do
        subject = PaymentRequestAuthorizer.new(valid_data)
        expect(subject.valid?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
      end

      it 'should allow existing user who has no transactions' do
        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: random_customer.email))
        expect(subject.valid?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
      end

      it 'should allow existing user having < 2 transactions in last twenty minutes and 2 transactions within a day' do
        create(:payment_braintree_transaction, customer_id: customer.customer_id,
                                               created_at: Time.zone.now.beginning_of_day)
        create(:payment_braintree_transaction, customer_id: customer.customer_id,
                                               created_at: Time.zone.now.beginning_of_day + 3.hours)

        time = transaction.created_at
        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email))

        Timecop.freeze(time) do
          expect(subject.valid?).to be_truthy
          expect(subject.errors.full_messages).to be_empty
        end
      end

      it 'should not allow existing user having > 1 transaction in last twenty minutes' do
        2.times { create(:payment_braintree_transaction, customer_id: customer.customer_id, created_at: Time.zone.now) }

        time = transaction.created_at
        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email))

        Timecop.freeze(time) do
          expect(subject.valid?).to be_falsy
          expect(subject.errors.full_messages).to include('Invalid request')
        end
      end

      it 'should not allow existing user having > 2 transactions with in a day' do
        2.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, created_at: Time.zone.now.beginning_of_day)
        }
        2.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, created_at: Time.zone.now + 6.hours)
        }

        time = transaction.created_at
        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email))

        Timecop.freeze(time) do
          expect(subject.valid?).to be_falsy
          expect(subject.errors.full_messages).to include('Invalid request')
        end
      end
    end

    context 'Invalid Captcha' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(false)
      end

      it 'should allow new user with valid email account' do
        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: 'support@sumofus.org'))
        VCR.use_cassette('payment_autherizer_valid_newuser_email') do
          expect(subject.valid?).to be_truthy
          expect(subject.errors.full_messages).to be_empty
        end
      end

      it 'should not allow new user with non existing email account' do
        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: 'test@abc.com'))
        VCR.use_cassette('payment_autherizer_invalid_newuser_email') do
          expect(subject.valid?).to be_falsy
          expect(subject.errors.full_messages).to include('Invalid request')
        end
      end

      it 'should allow existing user having more than 2 transactions' do
        3.times { create(:payment_braintree_transaction, customer_id: customer.customer_id) }

        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email))
        expect(subject.valid?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
      end

      it 'should not allow existing user with less than 2 transactions' do
        create(:payment_braintree_transaction, customer_id: customer.customer_id)

        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email))
        expect(subject.valid?).to be_falsy
        expect(subject.errors.full_messages).to include('Invalid request')
      end

      it 'should allow existing user having more than 3 actions before 3 days ago' do
        allow_any_instance_of(PaymentRequestAuthorizer::User).to receive(:actions_count).and_return(3)

        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email))
        expect(subject.valid?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
      end

      it 'should not allow existing user having less than 2 actions before 3 days ago' do
        allow_any_instance_of(PaymentRequestAuthorizer::User).to receive(:actions_count).and_return(1)

        subject = PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email))
        expect(subject.valid?).to be_falsy
        expect(subject.errors.full_messages).to include('Invalid request')
      end
    end
  end
end
