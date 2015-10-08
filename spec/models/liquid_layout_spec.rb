require 'rails_helper'

describe LiquidLayout do
  let(:layout) { create(:liquid_layout) }

  subject{ layout }

  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :content }
  it { is_expected.to respond_to :pages }
  it { is_expected.to respond_to :partial_names }
  it { is_expected.to respond_to :partial_refs }

  describe "is valid" do
    after :each do
      expect(layout).to be_valid
    end

    it "with a reference to a partial that does exist" do
      create :liquid_partial, title: 'existent'
      layout.content = "<div>{% include 'existent' %}</div>"
    end
  end

  describe "is invalid" do
    after :each do
      expect(layout).to be_invalid
    end

    it "with a blank title" do
      layout.title = " "
    end

    it "with a blank content" do
      layout.content = " "
    end

    it "with a reference to a partial that doesn't exist" do
      layout.content = "<div>{% include 'nonexistent' %}</div>"
    end
  end

  describe '.default' do
    before do
      create(:liquid_layout, title: 'default')
    end

    it 'returns default layout' do
      expect(LiquidLayout.default.title).to eq('default')
    end
  end

  describe 'plugin_refs' do

    it 'has all the plugins from its partials as length two arrays' do
      pe = create :liquid_partial, title: 'e', content: '<p>{{ plugins.e[ref] }}</p>'
      pd = create :liquid_partial, title: 'd', content: '<p>{{ plugins.d[ref] }}</p>'
      pc = create :liquid_partial, title: 'c', content: '<p>{% include "e" %} {{ plugins.c[ref] }}</p>'
      pb = create :liquid_partial, title: 'b', content: '<p>{% include "e", ref: "lol" %} {{ plugins.b[ref] }}</p>'
      pa = create :liquid_partial, title: 'a', content: '<p>{% include "b", ref: "heyy" %}</p>{% include "c" %} {{ plugins.a[ref] }}'
      layout.content = '{% include "a" %} {% include "d", ref: "wink" %}'
      expect(layout.plugin_refs).to match_array [['a', nil], ['b', 'heyy'], ['c', nil], ['d', "wink"], ['e', nil], ['e', 'lol']]
    end

    it 'captures plugins from its own content' do
      pd = create :liquid_partial, title: 'd', content: '<p>{{ plugins.d[ref] }}</p>'
      layout.content = "<p>{{ plugins.thermometer[ref] }}</p>{% include 'd', ref: 'modal' %}"
      expect(layout.plugin_refs).to match_array [['thermometer', nil], ['d', "modal"]]
    end
  end
end

