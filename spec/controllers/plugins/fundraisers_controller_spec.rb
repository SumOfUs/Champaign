# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::FundraisersController do
  include_examples 'plugins controller', Plugins::Fundraiser, :plugins_fundraiser
end
