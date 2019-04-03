# frozen_string_literal: true

require 'rails_helper'

describe ChampaignLiquidFilters do
  # to define a liquid filter, you make a module with instance methods that
  # gets included by liquid. You can't make them module_functions, so here
  # we extend a generic class to call the filter
  subject { Class.new.extend(ChampaignLiquidFilters) }

  describe 'select_option' do
    let(:base_options) do
      '<option value="DM">Dominique</option>
       <option value="SV">El Salvador</option>
       <option value="ES">Espagne</option>
       <option value="EE">Estonie</option>'
    end

    it 'does not add selected if one is already selected with attribute' do
      options = base_options + '<option value="FJ" selected="selected">Fidji</option>'
      expect(subject.select_option(options, 'ES')).to eq options
    end

    it 'does not add selected if one is already selected with property"' do
      options = base_options + '<option selected value="FJ">Fidji</option>'
      expect(subject.select_option(options, 'ES')).to eq options
    end

    it 'correctly selects with single quotes' do
      options = base_options.tr('"', "'")
      processed = subject.select_option(options, 'ES')
      expect(processed).to include("<option value='ES' selected >Espagne</option>")
      expect(processed.scan('selected').size).to eq 1
    end

    it 'correctly selects with double quotes' do
      options = base_options.tr("'", '"')
      processed = subject.select_option(options, 'ES')
      expect(processed).to include('<option value="ES" selected >Espagne</option>')
      expect(processed.scan('selected').size).to eq 1
    end
  end
end
