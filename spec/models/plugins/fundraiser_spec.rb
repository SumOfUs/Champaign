require 'rails_helper'

describe Plugins::Fundraiser do
  let(:fundraiser) { create :plugins_fundraiser }

  subject{ fundraiser }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :ref }
  it { is_expected.to respond_to :page }

  it 'is included in Plugins.registered' do
    expect(Plugins.registered).to include(Plugins::Fundraiser)
  end

end
