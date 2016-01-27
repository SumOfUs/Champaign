require 'rails_helper'

describe ApplicationController do

  context 'localization' do

    around(:each) do |spec|
      I18n.locale = I18n.default_locale
      spec.run
      I18n.locale = I18n.default_locale
    end

    describe 'localize_from_page_id' do

      let(:english) { create :language, code: 'en' }
      let!(:page) { create :page, language: english }

      before :each do
        allow(controller).to receive(:set_locale)
      end

      it 'does nothing if page_id is blank' do
        allow(controller).to receive(:params).and_return({page_id: nil})
        controller.send(:localize_from_page_id)
        expect(controller).not_to have_received(:set_locale)
      end

      it 'does nothing if page has no language' do
        page.update_attributes(language_id: nil)
        allow(controller).to receive(:params).and_return({page_id: page.id})
        controller.send(:localize_from_page_id)
        expect(controller).not_to have_received(:set_locale)
      end

      it 'sets locale with page language code' do
        allow(controller).to receive(:params).and_return({page_id: page.id})
        controller.send(:localize_from_page_id)
        expect(controller).to have_received(:set_locale).with('en')
      end
    end

    describe 'set_locale' do

      it 'sets the locale if it is a known locale' do
        expect(I18n.locale).to eq :en
        expect{ controller.send(:set_locale, 'fr') }.not_to raise_error
        expect(I18n.locale).to eq :fr
      end

      it 'does nothing when passed an unknown locale' do
        expect(I18n.locale).to eq :en
        expect{ controller.send(:set_locale, 'es') }.not_to raise_error
        expect(I18n.locale).to eq :en
      end

      it 'does nothing when passed a blank locale' do
        expect(I18n.locale).to eq :en
        expect{ controller.send(:set_locale, nil) }.not_to raise_error
        expect(I18n.locale).to eq :en
      end
    end

  end

end
