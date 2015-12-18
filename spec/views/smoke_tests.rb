require 'rails_helper'
require_relative 'shared_examples'

describe 'campaigns/' do
  include_examples "view smoke test", :campaign
end

describe 'liquid_partials/' do
  include_examples "view smoke test", :liquid_partial
end
