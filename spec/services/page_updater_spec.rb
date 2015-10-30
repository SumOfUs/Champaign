require 'rails_helper'

describe PageUpdater do

  # these are really integration tests, but I want to test it does the things
  # that will actually make or break the campaigner experience

  let!(:action_partial) { create :liquid_partial, title: 'action', content: '{{ plugins.action[ref].lol }}' }
  let!(:thermo_partial) { create :liquid_partial, title: 'thermometer', content: '{{ plugins.thermometer[ref].lol }}' }
  let(:liquid_layout) { create :liquid_layout, :default }
  let(:page) { create :page, liquid_layout: liquid_layout }
  let(:pupdater) { PageUpdater.new(page) }
  let(:simple_changes) { {page: {title: 'howdy folks!', content: 'Did they get you to trade'}} }
  let(:breaking_changes) { {page: {title: nil, content: 'your heros for ghosts'}} }
  let(:thermo_plugin) { page.plugins.select{|p| p.name == "Thermometer"}.first }
  let(:action_plugin) { page.plugins.select{|p| p.name == "Action"}.first }

  subject{ pupdater }

  it { is_expected.to respond_to :update }
  it { is_expected.to respond_to :errors }
  it { is_expected.to respond_to :refresh? }

  describe 'update' do

    it 'returns true if successful' do
      expect(pupdater.update(simple_changes)).to eq true
    end

    it 'returns false if errors' do
      expect(pupdater.update(breaking_changes)).to eq false
    end

    it 'can update one plugin' do
      pupdater.update({plugins_action: {cta: "Walk on part in the war", id: action_plugin.id, name: action_plugin.name}})
      expect(action_plugin.reload.cta).to eq "Walk on part in the war"
    end

    it 'can update multiple plugin' do
      pupdater.update({plugins_action: {cta: "Walk on part in the war", id: action_plugin.id, name: action_plugin.name}, plugins_thermometer: {offset: 1612, id: thermo_plugin.id, name: thermo_plugin.name} })
      expect(action_plugin.reload.cta).to eq "Walk on part in the war"
      expect(thermo_plugin.reload.offset).to eq 1612
    end

    it 'can update the page' do
      pupdater.update({page: {content: "for a leading role in the cage"}})
      expect(page.reload.content).to eq "for a leading role in the cage"
    end

    it 'can update plugins and page together' do
      pupdater.update({plugins_action: {cta: "Walk on part in the war", id: action_plugin.id, name: action_plugin.name}, page: {content: "for a leading role in the cage"}})
      expect(action_plugin.reload.cta).to eq "Walk on part in the war"
      expect(page.reload.content).to eq "for a leading role in the cage"
    end

    it "updates the plugins even if it can't update the page" do
      params = {plugins_thermometer: {offset: 1492, id: thermo_plugin.id, name: thermo_plugin.name}, page: {title: nil, content: 'hot air for a cool breeze'}}
      expect(pupdater.update(params)).to eq false
      expect(thermo_plugin.reload.offset).to eq 1492
      expect(page.reload.content).not_to eq "hot air for a cool breeze"
    end

    it "updates the page even if it can't update the plugins" do
      params = {plugins_thermometer: {offset: -100, id: thermo_plugin.id, name: thermo_plugin.name}, page: {content: 'cold comfort for change'}}
      expect(pupdater.update(params)).to eq false
      expect(thermo_plugin.reload.offset).not_to eq -100
      expect(page.reload.content).to eq "cold comfort for change"
    end

    it 'raises ActiveRecord::RecordNotFound if missing plugin name' do
      params = {plugins_thermometer: {offset: 100, id: thermo_plugin.id} }
      expect{ pupdater.update(params) }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'raises ActiveRecord::RecordNotFound if missing plugin id' do
      params = {plugins_thermometer: {offset: 100, name: thermo_plugin.name } }
      expect{ pupdater.update(params) }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'updates the page active to true' do
      page.active = false
      page.save
      expect(page.reload.active).to eq false
      params = {page: {active: true} }
      expect( pupdater.update(params) ).to eq true
      expect( page.reload.active).to eq true
    end

    it 'updates the page active to false' do
      page.active = true
      page.save
      expect(page.reload.active).to eq true
      params = {page: {active: false} }
      expect( pupdater.update(params) ).to eq true
      expect( page.reload.active).to eq false
    end

    it 'can update shares'

  end

  describe 'errors' do

    it 'returns errors nested by page' do
      params = {plugins_thermometer: {offset: 1492, id: thermo_plugin.id, name: thermo_plugin.name}, page: {title: nil, content: 'hot air for a cool breeze'}}
      expect(pupdater.update(params)).to eq false
      expect(pupdater.errors).to eq({page: {title: "can't be blank"}})
    end

    it 'returns errors nested by plugin' do
      params = {plugins_thermometer: {offset: -149, id: thermo_plugin.id, name: thermo_plugin.name}, page: {title: "yooo", content: 'hot air for a cool breeze'}}
      expect(pupdater.update(params)).to eq false
      expect(pupdater.errors).to eq({plugins_thermometer: {offset: "must be greater than or equal to 0"}})
    end
  end

  describe 'refresh?' do

    let(:alt_liquid_layout) { create :liquid_layout, :thermometer }

    it 'returns false before update called' do
      expect(pupdater.refresh?).to eq false
    end

    it 'returns false if nothing changed' do
      pupdater.update({page: {content: page.content}})
      expect(pupdater.refresh?).to eq false
    end

    it 'returns false if several non-refresh fields were updated' do
      pupdater.update({plugins_action: {cta: "Walk on part in the war", id: action_plugin.id, name: action_plugin.name}, page: {content: "for a leading role in the cage"}})
      expect(pupdater.refresh?).to eq false
    end

    it 'returns true if liquid_layout_id was changed' do
      pupdater.update({page: {liquid_layout_id: alt_liquid_layout.id}})
      expect(pupdater.refresh?).to eq true
    end

    it 'returns true if liquid_layout was changed' do
      pupdater.update({page: {liquid_layout: alt_liquid_layout}})
      expect(pupdater.refresh?).to eq true
    end
  end
end
