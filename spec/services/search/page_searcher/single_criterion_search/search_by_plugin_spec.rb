# frozen_string_literal: true

require 'rails_helper'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'by plugin' do
        let!(:petition_partial) { create(:liquid_partial, title: 'petition') }
        let!(:thermometer_partial) { create(:liquid_partial, title: 'thermometer') }

        let!(:default_layout) do
          create(:liquid_layout, :default, title: 'contains petition and thermometer plugin')
        end

        let!(:petition_layout) do
          create(:liquid_layout, :petition, title: 'contains petition plugin')
        end

        let!(:petition_page) do
          create(:page, liquid_layout: petition_layout, title: 'petition page - with petition layout')
        end

        let!(:thermometer_page) do
          create(
            :page,
            liquid_layout: default_layout,
            title: 'thermometer page - with default layout, petition toggled off'
          )
        end

        let!(:default_page) do
          create(
            :page,
            liquid_layout: default_layout,
            title: 'default page - with active thermometer and petition plugins'
          )
        end

        let!(:thermometer_page_thermometer) { create(:plugins_thermometer, page: thermometer_page) }
        let!(:default_page_thermometer) { create(:plugins_thermometer, page: default_page) }
        let!(:petition_page_thermometer) { create(:plugins_thermometer, page: petition_page, active: false) }

        let!(:petition_page_petition) { create(:plugins_petition, page: petition_page, active: true) }
        let!(:default_page_petition) { create(:plugins_petition, page: default_page, active: true) }
        let!(:thermometer_page_petition) { create(:plugins_petition, page: thermometer_page, active: false) }

        describe 'returns all pages when searching' do
          it 'with an empty array' do
            expect(Search::PageSearcher.new(plugin_type: []).search).to match_array(Page.all)
          end
          it 'with nil' do
            expect(Search::PageSearcher.new(plugin_type: nil).search).to match_array(Page.all)
          end
          it 'with empty string' do
            expect(Search::PageSearcher.new(plugin_type: '').search).to match_array(Page.all)
          end
        end

        describe 'returns no pages when searching' do
          it 'with a plugin has been turned off on all of the pages' do
            expect(Search::PageSearcher.new(plugin_type: ['Plugins::ActionsThermometer']).search).to match_array([])
          end
          it 'with a plugin that does not exist' do
            expect(Search::PageSearcher.new(plugin_type: ['Plugins::UnusedPlugin']).search).to match_array([])
          end
          it 'with several plugins where a page matches one but not the rest of them' do
            search = Search::PageSearcher.new(
              plugin_type: ['Plugins::ActionsThermometer', 'Plugins::UnusedPlugin']
            ).search
            expect(search).to match_array([])
          end

          it 'with several plugins where at least one page matches by criteria but at least one of the' \
          'requested plugins is deactivated' do
            default_page_thermometer.update(active: false)
            search = Search::PageSearcher.new(plugin_type: ['Plugins::Petition', 'Plugins::ActionsThermometer']).search
            expect(search).to match_array([])
          end
        end

        describe 'returns some pages when searching' do
          it 'with a plugin that is active on several pages' do
            expect(default_page_thermometer.page).to eq(default_page)

            default_page_thermometer.update(active: true)
            thermometer_page_thermometer.update(active: true)

            expect(default_page_thermometer.active).to eq(true)
            expect(thermometer_page_thermometer.active).to eq(true)
            expect(thermometer_page_thermometer.page).to eq(thermometer_page)
            expect(Search::PageSearcher.new(plugin_type: ['Plugins::ActionsThermometer']).search).to(
              match_array([default_page, thermometer_page])
            )
          end

          it 'with several plugins, if a page exists where all of them are active' do
            default_page_thermometer.update(active: true)
            default_page_petition.update(active: true)

            petition_page_petition.update(active: true)
            thermometer_page_petition.update(active: false)

            petition_page_thermometer.update(active: false)
            thermometer_page_thermometer.update(active: true)

            expect(
              Search::PageSearcher.new(plugin_type: ['Plugins::Petition', 'Plugins::ActionsThermometer']).search
            ).to(match_array([default_page]))
          end
        end
      end
    end
  end
end
