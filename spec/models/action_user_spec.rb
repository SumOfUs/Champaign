require 'rails_helper'

describe ActionUser do

  let(:action_user) { create :action_user }
  subject { action_user }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :country }
  it { is_expected.to respond_to :first_name }
  it { is_expected.to respond_to :last_name }
  it { is_expected.to respond_to :city }
  it { is_expected.to respond_to :postal_code }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :address1 }
  it { is_expected.to respond_to :address2 }

end
