require 'rails_helper'

describe LiquidRenderer do

  let!(:body_partial) { create :liquid_partial, title: 'body_text', content: '<p>{{ content }}</p>' }
  let(:liquid_layout) { create :liquid_layout, content: "<h1>{{ title }}</h1> {% include 'body_text' %}" }
  let(:page) { create :page, liquid_layout: liquid_layout, content: 'sliiiiide to the left' }
  let(:renderer) { LiquidRenderer.new(page) }

  describe 'new' do
    it 'receives the correct arguments' do
      expect{
        LiquidRenderer.new(page, layout: liquid_layout, request_country: 'RD', member: {}, url_params: {hi: 'a'})
      }.not_to raise_error
    end

    it 'requires only page' do
      expect{
        LiquidRenderer.new(page)
      }.not_to raise_error
    end

    it 'does not receive arbitrary keyword arguments' do
      expect{
        LiquidRenderer.new(page, secondary_layout: liquid_layout)
      }.to raise_error(ArgumentError)
    end

    describe 'setting locale' do

      after :each do
        I18n.locale = I18n.default_locale
      end

      describe "leaves english as the locale when page" do
        it 'has no language' do
          page.language = nil
          LiquidRenderer.new(page, layout: liquid_layout)
          expect(I18n.locale).to eq :en
          expect(I18n.t('common.save')).to eq 'Save'
        end

        it "has a nonsense language code" do
          page.language = build :language, code: 'xxx'
          LiquidRenderer.new(page, layout: liquid_layout)
          expect(I18n.locale).to eq :en
          expect(I18n.t('common.save')).to eq 'Save'
        end

        it "has an unsupported language code" do
          page.language = build :language, code: 'es'
          LiquidRenderer.new(page, layout: liquid_layout)
          expect(I18n.locale).to eq :en
          expect(I18n.t('common.save')).to eq 'Save'
        end
      end
    end
  end

  describe "render" do
    it "returns an html string with the title" do
      expect(renderer.render).to include("<h1>#{page.title}</h1>")
    end

    it "renders the partial with the content" do
      expect(renderer.render).to include("<p>#{page.content}</p>")
    end

    describe 'handles a missing translation' do

      it 'by raising an error in test' do
        expect(Rails.env.test?).to eq true
        liquid_layout.update_attributes(content: "{{ 'fundraiser.lunacy' | t }}")
        expect{ renderer.render }.to raise_error I18n::TranslationMissing
      end

      it 'by raising an error in development' do
        allow(Rails).to receive(:env).and_return "development".inquiry
        expect(Rails.env.development?).to eq true
        liquid_layout.update_attributes(content: "{{ 'fundraiser.lunacy' | t }}")
        expect{ renderer.render }.to raise_error I18n::TranslationMissing
      end

      it 'by showing the best effort on production' do
        allow(Rails).to receive(:env).and_return "production".inquiry
        expect(Rails.env.production?).to eq true
        liquid_layout.update_attributes(content: "{{ 'fundraiser.lunacy' | t }}")
        expect{ renderer.render }.not_to raise_error
        expect( renderer.render ).to include('lunacy');
      end
    end

    it 'fills in localized string' do
      liquid_layout.update_attributes(content: "{{ 'common.confirm' | t }}")
      expect(renderer.render).to eq "Are you sure?"
    end

  end

  describe "default_markup" do
    it "reads a real file containing a title tag" do
      expect(renderer.default_markup).to include ("title")
    end

    it "reads a real file of reasonable length" do
      expect(renderer.default_markup.length).to be > 20
    end
  end

  describe "data" do
    it "should have string keys" do
      expect(renderer.data.keys.map(&:class).uniq).to eq [String]
    end

    it "should have expected keys" do
      expected_keys = ['plugins', 'ref', 'title', 'content', 'images', 'shares', 'country_option_tags', 'url_params', 'primary_image', 'follow_up_url']
      actual_keys = renderer.data.keys
      expected_keys.each do |expected_key|
        expect(actual_keys).to include(expected_key)
      end
    end
  end

end
