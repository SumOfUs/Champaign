require 'rails_helper'

describe Plugins::Action do
  
  let(:action) { create :plugins_action }

  subject{ action }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :description }
  it { is_expected.to respond_to :target }
  it { is_expected.to respond_to :cta }
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :active }
  it { is_expected.to respond_to :ref }

  it 'is invalid without cta' do
    action.cta = ""
    expect(action).to be_invalid
  end

  it "is valid without target" do
    action.target = ""
    expect(action).to be_valid
  end

end
