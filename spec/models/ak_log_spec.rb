require 'rails_helper'

describe AkLog do
  let(:aklog) { create :ak_log }
  subject { aklog }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :request_body }
  it { is_expected.to respond_to :response_body }
  it { is_expected.to respond_to :response_status }
  it { is_expected.to respond_to :resource }
end
