require 'rails_helper'

describe Payment::GoCardless::Customer do

  let(:customer) { build :payment_go_cardless_customer }
  subject { customer }

  it { is_expected.to respond_to :go_cardless_id }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :given_name }
  it { is_expected.to respond_to :family_name }
  it { is_expected.to respond_to :postal_code }
  it { is_expected.to respond_to :country_code }
  it { is_expected.to respond_to :language }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  # Associations
  it { is_expected.to respond_to :member }
  it { is_expected.to respond_to :member_id }
  it { is_expected.to respond_to :payment_methods }
  it { is_expected.to respond_to :transactions }
  it { is_expected.to respond_to :subscriptions }

  # Fields passed back from GoCardless that we don't record
  it { is_expected.to_not respond_to :address_line1 }
  it { is_expected.to_not respond_to :address_line2 }
  it { is_expected.to_not respond_to :address_line3 }
  it { is_expected.to_not respond_to :city }
  it { is_expected.to_not respond_to :region }
  it { is_expected.to_not respond_to :swedish_identity_number }

  describe 'associations' do
    it "associates transactions with GoCardless::Transactions's" do
      expect{
        customer.transactions = [build(:payment_go_cardless_transaction), build(:payment_go_cardless_transaction)]
      }.not_to raise_error
    end

    it "associates payment_methods with GoCardless::PaymentMethod's" do
      expect{
        customer.payment_methods = [build(:payment_go_cardless_payment_method), build(:payment_go_cardless_payment_method)]
      }.not_to raise_error
    end

    it "associates subscriptions with GoCardless::Subscription's" do
      expect{
        customer.subscriptions = [build(:payment_go_cardless_subscription), build(:payment_go_cardless_subscription)]
      }.not_to raise_error
    end
  end

  describe 'validation' do
    before :each do
      expect(customer).to be_valid
    end

    it 'rejects blank go_cardless_id' do
      customer.go_cardless_id = ''
      expect(customer).to be_invalid
    end
  end

end
