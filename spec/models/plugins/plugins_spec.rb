require 'rails_helper'

describe Plugins do

  let(:english) { create :language, code: 'en' }
  let(:french) { create :language, code: 'fr' }
  let(:german) { create :language, code: 'de' }
  let(:page){ create :page }

  describe "create_for_page" do

    it "creates no plugins with a nil plugin_name" do
      expect{ Plugins.create_for_page(nil, page, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 0
      expect{ Plugins.create_for_page(nil, page, 'my-ref') }.to change{ Plugins::Petition.count }.by 0
    end

    it "creates no plugins with a nil page" do
      expect{ Plugins.create_for_page('thermometer', nil, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 0
      expect{ Plugins.create_for_page('petition', nil, 'my-ref') }.to change{ Plugins::Petition.count }.by 0
    end

    it "create no plugin if one already exists for that page and ref" do
      expect{ Plugins.create_for_page('thermometer', page, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 1
      expect{ Plugins.create_for_page('thermometer', page, 'my-ref') }.to change{ Plugins::Thermometer.count }.by 0
    end

    it "creates a thermometer plugin" do
      expect{ Plugins.create_for_page('thermometer', page, nil) }.to change{ Plugins::Thermometer.count }.by 1
    end

    it "creates an petition plugin" do
      expect{ Plugins.create_for_page('petition', page, nil) }.to change{ Plugins::Petition.count }.by 1
    end

    it "attaches the page to the plugin" do
      Plugins.create_for_page('petition', page, nil)
      expect(Plugins::Petition.last.page).to eq page
    end

    it "attaches the ref to plugin" do
      Plugins.create_for_page('petition', page, 'zebra')
      expect(Plugins::Petition.last.ref).to eq 'zebra'
    end

    describe 'translating defaults' do

      describe 'into German' do
        before :each do
          page.update_attributes(language: german)
        end

        it 'works for petitions' do
          Plugins.create_for_page('petition', page, nil)
          expect(Plugins::Petition.last.cta).to eq 'Petition Unterschreiben'
        end

        it 'works for fundraisers' do
          Plugins.create_for_page('fundraiser', page, nil)
          expect(Plugins::Fundraiser.last.title).to eq 'Spenden Sie jetzt!'
        end

        it 'works for thermometers' do
          Plugins.create_for_page('thermometer', page, nil)
          thermometer = Plugins::Thermometer.last
          expect(thermometer.offset).to eq 0
          expect(thermometer.goal).to eq 100
        end
      end

      describe 'into French' do
        before :each do
          page.update_attributes(language: french)
        end

        it 'works for petitions' do
          Plugins.create_for_page('petition', page, nil)
          expect(Plugins::Petition.last.cta).to eq 'Signez la pétition'
        end

        it 'works for fundraisers' do
          Plugins.create_for_page('fundraiser', page, nil)
          expect(Plugins::Fundraiser.last.title).to eq 'Don maintenant'
        end

        it 'works for thermometers' do
          Plugins.create_for_page('thermometer', page, nil)
          thermometer = Plugins::Thermometer.last
          expect(thermometer.offset).to eq 0
          expect(thermometer.goal).to eq 100
        end
      end

      describe 'into English' do
        before :each do
          page.update_attributes(language: english)
        end

        it 'works for petitions' do
          Plugins.create_for_page('petition', page, nil)
          expect(Plugins::Petition.last.cta).to eq 'Sign the petition'
        end

        it 'works for fundraisers' do
          Plugins.create_for_page('fundraiser', page, nil)
          expect(Plugins::Fundraiser.last.title).to eq 'Donate now'
        end

        it 'works for thermometers' do
          Plugins.create_for_page('thermometer', page, nil)
          thermometer = Plugins::Thermometer.last
          expect(thermometer.offset).to eq 0
          expect(thermometer.goal).to eq 100
        end
      end

      describe 'without language falls back to english' do
        before :each do
          page.update_attributes(language: nil)
        end

        it 'works for petitions' do
          expect(page.language).to be_nil
          Plugins.create_for_page('petition', page, nil)
          expect(Plugins::Petition.last.cta).to eq 'Sign the petition'
        end

        it 'works for fundraisers' do
          expect(page.language).to be_nil
          Plugins.create_for_page('fundraiser', page, nil)
          expect(Plugins::Fundraiser.last.title).to eq 'Donate now'
        end

        it 'works for thermometers' do
          expect(page.language).to be_nil
          Plugins.create_for_page('thermometer', page, nil)
          thermometer = Plugins::Thermometer.last
          expect(thermometer.offset).to eq 0
          expect(thermometer.goal).to eq 100
        end
      end
    end
  end

  describe "data_for_view" do

    describe 'with plugins' do
      before :each do
        Plugins.create_for_page('thermometer', page, 'stripey')
        Plugins.create_for_page('petition',    page, 'swiper')
        @thermometer = Plugins::Thermometer.last
        @petition = Plugins::Petition.last
        expect(page.plugins).to match_array [@thermometer, @petition]
      end

      it "namespaces all the plugins according to their ref" do
        data_for_view = Plugins.data_for_view(page)
        expect(data_for_view[:plugins]['petition']).to have_key 'swiper'
        expect(data_for_view[:plugins]['petition']['swiper']).to eq @petition.liquid_data
        expect(data_for_view[:plugins]['thermometer']).to have_key 'stripey'
        expect(data_for_view[:plugins]['thermometer']['stripey']).to eq @thermometer.liquid_data
      end

      it "namespaces refless plugins under the default ref returned in top level hash" do
        @petition.ref = nil
        @petition.save!
        data_for_view = Plugins.data_for_view(page)
        expect(data_for_view[:plugins]['petition'].keys[0]).to eq data_for_view[:ref]
      end

      it 'can receive supplemental data ' do
        expect{ Plugins.data_for_view(page, {some: 'stuff'}) }.not_to raise_error
      end

    end
  end
end
