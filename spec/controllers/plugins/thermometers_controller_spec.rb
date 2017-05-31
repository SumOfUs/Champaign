# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::ThermometersController do
  include_examples 'plugins controller', Plugins::Thermometer, :plugins_thermometer
end
