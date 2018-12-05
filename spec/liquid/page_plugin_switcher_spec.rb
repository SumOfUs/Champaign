# frozen_string_literal: true

require 'rails_helper'

describe PagePluginSwitcher do
  let!(:petition_partial) { create :liquid_partial, title: 'petition', content: '{{ plugins.petition[ref] }}' }
  let!(:thermo_partial) { create :liquid_partial, title: 'thermo', content: '{{ plugins.actions_thermometer[ref] }}' }
  let!(:petition_nested_thermo_partial) do
    create :liquid_partial, title: 'petition_nested_thermo', content: '{{ plugins.petition[ref] }}{% include "thermo" %}'
  end

  let(:blank_layout) { create :liquid_layout, title: 'blank', content: '<h1>yoooo</h1>' }
  let(:both_refless_layout) { create :liquid_layout, title: 'both_refless', content: '{% include "petition" %} {% include "thermo" %}' }
  let(:petition_ref_layout) { create :liquid_layout, title: 'petition_ref', content: '{% include "petition", ref: "modal" %} ' }
  let(:thermo_petition_ref_layout) { create :liquid_layout, title: 'petition_ref', content: '{% include "petition", ref: "modal" %} {% include "thermo" %}' }
  let(:many_petition_layout) { create :liquid_layout, title: 'many_petition', content: '{% include "petition", ref: "a" %} {% include "petition", ref: "b" %} {% include "petition" %}' }
  let(:nested_refless_layout) { create :liquid_layout, title: 'nested_refless', content: '{% include "petition_nested_thermo" %}' }

  let!(:page) { create :page, liquid_layout: both_refless_layout }
  let!(:switcher) { PagePluginSwitcher.new(page) }

  describe '.switch' do
    describe 'creating' do
      it 'creates missing plugins when using the same template' do
        page.plugins.each(&:destroy)
        expect(page.plugins).to be_empty
        expect(page.liquid_layout).to eq both_refless_layout
        expect { switcher.switch(both_refless_layout) }.to change { Plugins::Petition.count }.by(1).and change { Plugins::ActionsThermometer.count }.by 1
        expect(page.plugins.size).to eq 2
      end

      it 'creates new plugins when switching to a template with more plugins' do
        expect { switcher.switch(many_petition_layout) }.to change { Plugins::Petition.count }.by(2).and change { Plugins::ActionsThermometer.count }.by -1
        expect(page.plugins.size).to eq 3
      end

      it 'creates with a ref if present' do
        expect { switcher.switch(petition_ref_layout) }.to change { Plugins::Petition.count }.by 0
        created = Plugins::Petition.last
        expect(created.page).to eq page
        expect(created.ref).to eq 'modal'
      end

      it 'creates without a ref if not present' do
        expect { switcher.switch(both_refless_layout) }.to change { Plugins::Petition.count }.by 0
        created = Plugins::Petition.last
        expect(created.page).to eq page
        expect(created.ref).to eq nil
      end

      it 'can create a version of a plugin for each layout' do
        expect { switcher.switch(many_petition_layout, petition_ref_layout) }
          .to change { Plugins::Petition.count }
          .from(1)
          .to(4)
        expect(page.plugins.map(&:class)).to match_array [Plugins::Petition] * 4
      end

      it 'can share a plugin between the two layouts' do
        expect { switcher.switch(both_refless_layout, many_petition_layout) }
          .to change { Plugins::Petition.count }
          .from(1)
          .to(3)
        expect(page.plugins.map(&:class)).to match_array([Plugins::Petition] * 3 + [Plugins::ActionsThermometer])
      end
    end

    describe 'replacing' do
      it 'does not replace instances if new template has same plugins' do
        plugins = page.plugins
        expect { switcher.switch(nested_refless_layout) }.to change { Plugins::Petition.count }.by 0
        expect(plugins).to all be_persisted
      end

      it 'does not replace instances if new template is old template' do
        plugins = page.plugins
        expect { switcher.switch(both_refless_layout) }.to change { Plugins::Petition.count }.by 0
        expect(plugins).to all be_persisted
      end

      it 'does replace instances if refs are different' do
        petition = page.plugins.select { |p| p.name == 'Petition' }.first
        expect(petition).to be_persisted
        expect { switcher.switch(thermo_petition_ref_layout) }.to change { Plugins::Petition.count }.by 0
        expect { petition.reload }.to raise_error ActiveRecord::RecordNotFound
        new_petition = page.plugins.select { |p| p.name == 'Petition' }.first
        expect(new_petition.id).not_to eq petition.id
      end

      it 'does replace one instance but not the other' do
        thermo = page.plugins.select { |p| p.name == 'ActionsThermometer' }.first
        expect { switcher.switch(thermo_petition_ref_layout) }.to change { Plugins::ActionsThermometer.count }.by 0
        expect { thermo.reload }.not_to raise_error
        new_thermo = page.plugins.select { |p| p.name == 'ActionsThermometer' }.first
        expect(new_thermo.id).to eq thermo.id
      end
    end

    describe 'destroying' do
      it 'destroys all plugins when switching to a template without plugins' do
        expect { switcher.switch(blank_layout) }
          .to change { Plugins::ActionsThermometer.count }.by(-1)
          .and change { Plugins::Petition.count }.by(-1)

        plugins = page.plugins
        plugins.each do |plugin|
          expect { plugin.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    it 'should not save the page itself' do
      switcher.switch(both_refless_layout)
      page.reload
      expect(page.liquid_layout).to eq both_refless_layout
      switcher.switch(many_petition_layout)
      expect(page.liquid_layout).to eq many_petition_layout
      expect(page.reload.liquid_layout).to eq both_refless_layout
    end
  end
end
