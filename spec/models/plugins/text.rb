# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::Text do
  subject(:text) { create(:plugins_text) }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :content }
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :active }
  it { is_expected.to respond_to :ref }

  it 'is valid without content' do
    text.content = ''
    expect(text).to be_valid
  end
end
