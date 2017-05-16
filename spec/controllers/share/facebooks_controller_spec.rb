# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

describe Share::FacebooksController do
  include_examples 'shares', Share::Facebook, 'facebook'

  let(:params) { { title: 'Foo', description: 'Bar' } }
  let(:new_defaults) { params }
end
