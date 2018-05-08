# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

describe Share::WhatsappsController do
  include_examples 'shares', Share::Whatsapp, 'whatsapp'

  let(:params) { { text: 'Bar' } }
  let(:new_defaults) { { text: 'Foo {LINK}' } }
end
