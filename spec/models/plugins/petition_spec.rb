require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::Petition do
  let(:petition) { create :plugins_petition }

  subject{ petition }

  include_examples "plugin with form", :plugins_petition

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :description }
  it { is_expected.to respond_to :target }
  it { is_expected.to respond_to :cta }
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :active }
  it { is_expected.to respond_to :ref }

  it 'is invalid without cta' do
    petition.cta = ""
    expect(petition).to be_invalid
  end

  it "is valid without target" do
    petition.target = ""
    expect(petition).to be_valid
  end

end
