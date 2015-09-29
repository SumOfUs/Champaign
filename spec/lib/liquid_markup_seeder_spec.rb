require 'spec_helper'
require './lib/liquid_markup_seeder'

describe LiquidMarkupSeeder do
  subject { LiquidMarkupSeeder }

  describe '.name' do
    it 'parses filename for partial' do
      filename = '/foo/bar/_partial.liquid'

      expect( subject.parse_name(filename) ).to eq('partial')
    end

    it 'parses filename for template' do
      filename = '/foo/bar/layout.liquid'

      expect( subject.parse_name(filename) ).to eq('layout')
    end
  end


  describe '.meta' do
    it 'returns array with class and name' do
      partial = subject.title_and_class('/foo/bar/_partial.liquid')
      expect(partial).to eq( ['partial', 'LiquidPartial'] )

      layout = subject.title_and_class('/foo/bar/layout.liquid')
      expect(layout).to eq( ['layout', 'LiquidLayout'] )
    end
  end
end
