# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::ThermometersController do
  include_examples 'plugins controller', Plugins::ActionsThermometer, :plugins_actions_thermometer
  include_examples 'plugins controller', Plugins::DonationsThermometer, :plugins_donations_thermometer
end
