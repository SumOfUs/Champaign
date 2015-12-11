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
  end

  describe "render" do
    it "returns an html string with the title" do
      expect(renderer.render).to include("<h1>#{page.title}</h1>")
    end

    it "renders the partial with the content" do
      expect(renderer.render).to include("<p>#{page.content}</p>")
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
