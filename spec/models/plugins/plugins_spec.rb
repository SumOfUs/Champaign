require 'rails_helper'

describe Plugins do

  let(:page){ create :page }

  describe "create_for_page" do

    it "creates no plugins with a nil plugin_name" do
      expect{ Plugins.create_for_page(nil, page, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 0
      expect{ Plugins.create_for_page(nil, page, 'my-ref') }.to change{ Plugins::Action.count }.by 0
    end

    it "creates no plugins with a nil page" do
      expect{ Plugins.create_for_page('thermometer', nil, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 0
      expect{ Plugins.create_for_page('action', nil, 'my-ref') }.to change{ Plugins::Action.count }.by 0
    end

    it "create no plugin if one already exists for that page and ref" do
      expect{ Plugins.create_for_page('thermometer', page, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 1
      expect{ Plugins.create_for_page('thermometer', page, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 0
    end

    it "creates a thermometer plugin" do
      expect{ Plugins.create_for_page('thermometer', page, nil) }.to change{ Plugins::Thermometer.count }.by 1
    end

    it "creates an action plugin" do
      expect{ Plugins.create_for_page('action', page, nil) }.to change{ Plugins::Action.count }.by 1
    end

    it "attaches the page to the plugin" do
      Plugins.create_for_page('action', page, nil)
      expect(Plugins::Action.last.page).to eq page
    end

    it "attaches the ref to plugin" do
      Plugins.create_for_page('action', page, 'zebra')
      expect(Plugins::Action.last.ref).to eq 'zebra'
    end
  end

  describe "data_for_view" do

    describe 'with plugins' do
    
      before :each do
        Plugins.create_for_page('thermometer', page, 'stripey')
        Plugins.create_for_page('action', page, 'swiper')
        @thermometer = Plugins::Thermometer.last
        @action = Plugins::Action.last
        expect(page.plugins).to match_array [@thermometer, @action]
      end

      it "namespaces all the plugins according to their ref" do
        data_for_view = Plugins.data_for_view(page)
        expect(data_for_view[:plugins]['action']).to have_key 'swiper'
        expect(data_for_view[:plugins]['action']['swiper']).to eq @action.liquid_data
        expect(data_for_view[:plugins]['thermometer']).to have_key 'stripey'
        expect(data_for_view[:plugins]['thermometer']['stripey']).to eq @thermometer.liquid_data
      end

      it "namespaces refless plugins under the default ref returned in top level hash" do
        @action.ref = nil
        @action.save!
        data_for_view = Plugins.data_for_view(page)
        expect(data_for_view[:plugins]['action'].keys[0]).to eq data_for_view[:ref]
      end

      it 'can receive supplemental data ' do
        expect{ Plugins.data_for_view(page, {some: 'stuff'}) }.not_to raise_error
      end

    end

  end

end
