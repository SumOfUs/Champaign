# frozen_string_literal: true

require 'rails_helper'

describe PaymentRequestAuthorizer do
  include Rails.application.routes.url_helpers

  let(:page) { create(:page, publish_status: 'published') }

  let(:customer) do
    @customer ||= begin
      attrs = FactoryBot.attributes_for(:payment_braintree_customer)
      Payment::Braintree::Customer.create(attrs)
    end
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
        expect(subject.errors.size).to eql 3
        expect(subject.errors.full_messages).to include("Email can't be blank",
                                                        "Recaptcha can't be blank", "Action can't be blank")
      end
    end

    context 'Existing user with valid captcha and 2 transactions within 20 mins' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
        2.times { create(:payment_braintree_transaction, customer_id: customer.customer_id) }
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return false' do
        time = transaction.created_at
        Timecop.freeze(time) do
          expect(subject.valid?).to be_falsy
          expect(subject.errors.full_messages).to include('Invalid request')
        end
      end
    end

    context 'Existing user with valid captcha and more than 3 transactions within a day' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)

        time = Time.now.beginning_of_day
        2.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, created_at: time)
        }
        1.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, created_at: time + 2.hours)
        }
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return false' do
        time = transaction.created_at

        Timecop.freeze(time) do
          expect(subject.valid?).to be_falsy
          expect(subject.errors.full_messages).to include('Invalid request')
        end
      end
    end

    context 'Existing user with valid captcha and 2 transaction within 20 mins' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
        1.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id)
        }
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return true' do
        time = Payment::Braintree::Transaction.last.created_at

        Timecop.freeze(time) do
          expect(subject.valid?).to be_truthy
          expect(subject.errors.full_messages).to be_empty
        end
      end
    end

    context 'Existing user with valid captcha and 3 transactions within 1 day' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
        time = Time.now.beginning_of_day
        1.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, created_at: time)
        }
        1.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, created_at: time + 2.hours)
        }
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return true' do
        time = transaction.created_at
        Timecop.freeze(time) do
          expect(subject.valid?).to be_truthy
          expect(subject.errors.full_messages).to be_empty
        end
      end
    end

    context 'Existing user with valid captcha and failed transactions' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
        5.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, status: 1)
        }
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return true' do
        time = transaction.created_at
        Timecop.freeze(time) do
          expect(subject.valid?).to be_truthy
          expect(subject.errors.full_messages).to be_empty
        end
      end
    end

    context 'Existing user with invalid captcha and failed transactions' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
        5.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, status: 1)
        }
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return true' do
        expect(subject.valid?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
      end
    end

    context 'Existing user with invalid captcha and less than 2 donations' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(false)
        1.times {
          create(:payment_braintree_transaction,
                 customer_id: customer.customer_id, status: 0)
        }
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return false' do
        expect(subject.valid?).to be_falsy
        expect(subject.errors.full_messages).to include('Invalid request')
      end
    end

    context 'Existing user With valid captcha and no donations' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
      end

      subject { PaymentRequestAuthorizer.new(valid_data.merge(email: customer.email)) }

      it 'should return true' do
        expect(subject.valid?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
      end
    end

    context 'An non existing user with invalid captcha' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(false)
        allow_any_instance_of(PaymentRequestAuthorizer).to receive(:new_customer?).and_return(true)
      end

      subject { PaymentRequestAuthorizer.new(valid_data) }

      it 'should return false' do
        subject.valid?
        expect(subject.valid?).to be_falsy
        expect(subject.errors.full_messages).to include('Invalid request')
      end
    end

    context 'An non existing user with valid captcha' do
      before do
        allow_any_instance_of(Recaptcha3).to receive(:human?).and_return(true)
        allow_any_instance_of(PaymentRequestAuthorizer).to receive(:new_customer?).and_return(true)
      end

      subject { PaymentRequestAuthorizer.new(valid_data) }

      it 'should return true' do
        subject.valid?
        expect(subject.valid?).to be_truthy
        expect(subject.errors.full_messages).to be_empty
      end
    end
  end
end
