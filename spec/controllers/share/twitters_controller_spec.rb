# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

describe Share::TwittersController do
  include_examples 'shares', Share::Twitter, 'twitter'

  let(:params) { { description: 'Bar' } }
  let(:new_defaults) { { description: 'Foo {LINK}' } }
end
