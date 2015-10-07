require 'rails_helper'

describe LiquidLayoutSwitcher do

  let!(:action_partial) { create :liquid_partial, title: 'action', content: '{{ plugins.action[ref] }}' }
  let!(:thermo_partial) { create :liquid_partial, title: 'thermo', content: '{{ plugins.thermometer[ref] }}' }
  let!(:action_nested_thermo_partial) do
    create :liquid_partial, title: 'action_nested_thermo', content: '{{ plugins.action[ref] }}{% include "thermo" %}'
  end

  let(:blank_layout) { create :liquid_layout, title: 'blank', content: '<h1>yoooo</h1>'}
  let(:both_refless_layout) { create :liquid_layout, title: 'both_refless', content: '{% include "action" %} {% include "thermo" %}'}
  let(:action_ref_layout) { create :liquid_layout, title: 'action_ref', content: '{% include "action", ref: "modal" %}'}
  let(:page) { create :page, liquid_layout: both_refless_layout }

  let(:switcher) { LiquidLayoutSwitcher.new(page) }

  describe ".switch" do

    describe 'creating' do

      describe 'when using the same template' do

        before :each do
          expect(page.plugins).to be_empty
          expect(page.liquid_layout).to eq both_refless_layout
        end

        after :each do
          expect(page.plugins.size).to eq 2
        end

        it 'creates missing action' do
          expect{ switcher.switch(both_refless_layout) }.to change{ Plugins::Action.count }.by 1
        end

        it 'creates missing thermometer' do
          expect{ switcher.switch(both_refless_layout) }.to change{ Plugins::Thermometer.count }.by 1
        end

      end

      it 'creates new plugins when switching to a template with more plugins' do
        puts "both_refless_layout.plugin_refs #{both_refless_layout.plugin_refs}"
        expect{ switcher.switch(blank_layout) }.to change{ Plugins::Action.count }.by 0
        expect( page.plugins.size ).to eq 0
        expect{ switcher.switch( both_refless_layout )}.to change{ Plugins::Action.count }.by 1
        expect( page.plugins.size ).to eq 2
      end

      it 'creates with a ref if present' do
        puts "action_ref_layout.plugin_refs #{action_ref_layout.plugin_refs}"
        expect{ switcher.switch( action_ref_layout )}.to change{ Plugins::Action.count }.by 1
        created = Plugins::Action.last
        expect( created.page ).to eq page
        expect( created.ref ).to eq 'modal'
      end

      it 'creates without a ref if not present' do
        expect{ switcher.switch( both_refless_layout )}.to change{ Plugins::Action.count }.by 1
        created = Plugins::Action.last
        expect( created.page ).to eq page
        expect( created.ref ).to eq nil
      end

    end

    describe 'switching' do

      it 'does not replace instances if new template has same plugins'
      it 'does not replace instances if new template is old template'
      it 'does replace instances if refs are different'
      it 'does can replace one instance but not the other'
    end

    describe 'destroying' do
      it 'destroys all plugins when switching to a template without plugins'
    end

  end

end
