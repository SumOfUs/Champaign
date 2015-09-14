require 'rails_helper'
require_relative 'shared_examples'

describe Share::TwittersController do
  include_examples "shares", Share::Twitter, 'twitter'

  let(:share){ instance_double('Share::Twitter') }
  let(:params){ { description: 'Bar' } }
  let(:new_defaults) { { description: 'Foo {LINK}' }}

  before do
    allow(CampaignPage).to receive(:find).with('1'){ page }
  end
end

