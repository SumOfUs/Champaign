require 'rails_helper'

describe PagePluginSwitcher do

  let!(:action_partial) { create :liquid_partial, title: 'action', content: '{{ plugins.action[ref] }}' }
  let!(:thermo_partial) { create :liquid_partial, title: 'thermo', content: '{{ plugins.thermometer[ref] }}' }
  let!(:action_nested_thermo_partial) do
    create :liquid_partial, title: 'action_nested_thermo', content: '{{ plugins.action[ref] }}{% include "thermo" %}'
  end

  let(:blank_layout) { create :liquid_layout, title: 'blank', content: '<h1>yoooo</h1>'}
  let(:both_refless_layout) { create :liquid_layout, title: 'both_refless', content: '{% include "action" %} {% include "thermo" %}'}
  let(:action_ref_layout) { create :liquid_layout, title: 'action_ref', content: '{% include "action", ref: "modal" %} '}
  let(:thermo_action_ref_layout) { create :liquid_layout, title: 'action_ref', content: '{% include "action", ref: "modal" %} {% include "thermo" %}'}
  let(:many_action_layout) { create :liquid_layout, title: 'many_action', content: '{% include "action", ref: "a" %} {% include "action", ref: "b" %} {% include "action" %}'}
  let(:nested_refless_layout) { create :liquid_layout, title: 'nested_refless', content: '{% include "action_nested_thermo" %}' }

  let!(:page) { create :page, liquid_layout: both_refless_layout }
  let!(:switcher) { PagePluginSwitcher.new(page) }

  describe ".switch" do

    describe 'creating' do

      it 'creates missing plugins when using the same template' do
        page.plugins.each{ |p| p.destroy }
        expect(page.plugins).to be_empty
        expect(page.liquid_layout).to eq both_refless_layout
        expect{ switcher.switch(both_refless_layout) }.to change{ Plugins::Action.count }.by(1).and change{ Plugins::Thermometer.count }.by 1
        expect(page.plugins.size).to eq 2
      end

      it 'creates new plugins when switching to a template with more plugins' do
        expect{ switcher.switch( many_action_layout )}.to change{ Plugins::Action.count }.by(2).and change{ Plugins::Thermometer.count }.by -1
        expect( page.plugins.size ).to eq 3
      end

      it 'creates with a ref if present' do
        expect{ switcher.switch( action_ref_layout )}.to change{ Plugins::Action.count }.by 0
        created = Plugins::Action.last
        expect( created.page ).to eq page
        expect( created.ref ).to eq 'modal'
      end

      it 'creates without a ref if not present' do
        expect{ switcher.switch( both_refless_layout )}.to change{ Plugins::Action.count }.by 0
        created = Plugins::Action.last
        expect( created.page ).to eq page
        expect( created.ref ).to eq nil
      end

    end

    describe 'replacing' do

      it 'does not replace instances if new template has same plugins' do
        plugins = page.plugins
        expect{ switcher.switch(nested_refless_layout) }.to change{ Plugins::Action.count }.by 0
        expect(plugins).to all be_persisted
      end

      it 'does not replace instances if new template is old template' do
        plugins = page.plugins
        expect{ switcher.switch(both_refless_layout) }.to change{ Plugins::Action.count }.by 0
        expect(plugins).to all be_persisted
      end

      it 'does replace instances if refs are different'do
        action = page.plugins.select{|p| p.name == "Action" }.first
        expect(action).to be_persisted
        expect{ switcher.switch(thermo_action_ref_layout) }.to change{ Plugins::Action.count }.by 0
        expect{ action.reload }.to raise_error ActiveRecord::RecordNotFound
        new_action = page.plugins.select{|p| p.name == "Action" }.first
        expect(new_action.id).not_to eq action.id
      end

      it 'does replace one instance but not the other' do
        thermo = page.plugins.select{|p| p.name == "Thermometer" }.first
        expect{ switcher.switch(thermo_action_ref_layout) }.to change{ Plugins::Thermometer.count }.by 0
        expect{ thermo.reload }.not_to raise_error
        new_thermo = page.plugins.select{|p| p.name == "Thermometer" }.first
        expect(new_thermo.id).to eq thermo.id
      end
    end

    describe 'destroying' do

      it 'destroys all plugins when switching to a template without plugins' do
        plugins = page.plugins
        expect{ switcher.switch(blank_layout) }.to change{ Plugins::Thermometer.count }.by(-1).and change{ Plugins::Action.count }.by(-1)
        plugins.each do |plugin|
          expect{ plugin.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    it 'should not save the page itself' do
      switcher.switch(both_refless_layout)
      page.reload
      expect(page.liquid_layout).to eq both_refless_layout
      switcher.switch(many_action_layout)
      expect(page.liquid_layout).to eq many_action_layout
      expect(page.reload.liquid_layout).to eq both_refless_layout
    end

  end

end
