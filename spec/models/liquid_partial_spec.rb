require 'rails_helper'

describe LiquidPartial do
  
  let(:partial) { create(:liquid_partial) }

  subject{ partial }

  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :content }
  it { is_expected.to respond_to :plugin_name }
  it { is_expected.to respond_to :partial_names }
  it { is_expected.to respond_to :partial_refs }

  it { is_expected.not_to respond_to :one_plugin }

  describe "is valid" do

    after :each do
      expect(partial).to be_valid
    end

    it "with factory settings" do
    end

    it "with multiple references to the same plugin" do
      partial.content = "<div>{{ plugins.actions[ref].text }}</div>
                         <div>{{ plugins.actions[ref].wink }}</div>"
    end

    it "with a reference to a partial that does exist" do
      create :liquid_partial, title: 'existent'
      partial.content = "<div>{% include 'existent' %}</div>"
    end
  end

  describe "is invalid" do

    after :each do
      expect(partial).to be_invalid
    end

    it "with a blank title" do
      partial.title = " "
    end

    it "with a blank content" do
      partial.content = " "
    end

    it "with multiple references to different plugins" do
      partial.content = "<div>{{ plugins.actions[ref].text }}</div>
                         <div>{{ plugins.thermometer[ref].wink }}</div>"
    end

    it "with a reference to a partial that doesn't exist" do
      partial.content = "<div>{% include 'nonexistent' %}</div>"
    end
  end

  describe "plugin_refs" do

    describe 'without nested partials' do
      it 'returns its own plugin with the passed ref' do
        pa = create :liquid_partial, title: 'a', content: '<p>{{ plugins.my_plugin[ref] }}</p>'
        expect(pa.plugin_refs(ref: 'my_ref') ).to eq [['my_plugin', "my_ref"]]
      end

      it 'returns empty array if no plugins' do
        pa = create :liquid_partial, title: 'a', content: '<p>Fire in the hole!</p>'
        expect(pa.plugin_refs(ref: 'my_ref') ).to eq []
      end
    end

    describe 'finds plugins and refs from nested partials' do
      it 'from a partial nested in a pluginless partial' do
        pc = create :liquid_partial, title: 'c', content: '<p>{{ plugins.c[ref] }}</p>'
        pb = create :liquid_partial, title: 'b', content: '<p>{% include "c" %}</p>'
        pa = create :liquid_partial, title: 'a', content: '<p>{% include "b", ref: "heyy" %}</p>'
        expect(pa.plugin_refs).to eq [['c', nil]]
      end

      it 'with a tree of partials without plugins' do
        pe = create :liquid_partial, title: 'e', content: '<p>{{ plugins.e[ref] }}</p>'
        pd = create :liquid_partial, title: 'd', content: '<p>I like pasta</p>'
        pc = create :liquid_partial, title: 'c', content: '<p>{% include "e" %}{% include "d" %}</p>'
        pb = create :liquid_partial, title: 'b', content: '<p>{% include "e", ref: "lol" %}</p>'
        pa = create :liquid_partial, title: 'a', content: '<p>{% include "b", ref: "heyy" %}</p>{% include "c" %}'
        expect(pa.plugin_refs).to match_array [['e', 'lol'], ['e', nil]]
      end

      it 'with a tree of partials with different plugins' do
        pe = create :liquid_partial, title: 'e', content: '<p>{{ plugins.e[ref] }}</p>'
        pd = create :liquid_partial, title: 'd', content: '<p>{{ plugins.d[ref] }}</p>'
        pc = create :liquid_partial, title: 'c', content: '<p>{% include "e" %}{% include "d" %} {{ plugins.c[ref] }}</p>'
        pb = create :liquid_partial, title: 'b', content: '<p>{% include "e", ref: "lol" %} {{ plugins.b[ref] }}</p>'
        pa = create :liquid_partial, title: 'a', content: '<p>{% include "b", ref: "heyy" %}</p>{% include "c" %} {{ plugins.a[ref] }}'
        expect(pa.plugin_refs).to match_array [['a', nil], ['b', 'heyy'], ['c', nil], ['d', nil], ['e', nil], ['e', 'lol']]
      end

      it 'with multiple partials with the same plugin' do
        pc = create :liquid_partial, title: 'c', content: '<p>{{ plugins.my_plugin[ref] }}</p>'
        pb = create :liquid_partial, title: 'b', content: '<p>{{ plugins.my_plugin[ref] }}</p>'
        pa = create :liquid_partial, title: 'a', content: '<p>{% include "b", ref: "yay" %}</p>{% include "c" %}{{ plugins.my_plugin[ref] }}'
        expect(pa.plugin_refs).to match_array [['my_plugin', 'yay'], ['my_plugin', nil]]
        expect(pa.plugin_refs(ref: 'yay')).to match_array [['my_plugin', 'yay'], ['my_plugin', nil]]
        expect(pa.plugin_refs(ref: 'nae')).to match_array [['my_plugin', 'yay'], ['my_plugin', nil], ['my_plugin', 'nae']]
      end

    end

    describe 'with deep nesting' do
      it 'does not get trapped in cyclical references' do
        pa = create :liquid_partial, title: 'a', content: 'wasssup'
        pb = create :liquid_partial, title: 'b', content: '<p>{% include "a" %}</p>{{ plugins.b[ref] }}'
        pa.content = '<p>{% include "b" %}</p>{{ plugins.a[ref] }}'
        pa.save
        expect(pa.plugin_refs).to eq [['a', nil], ['b', nil]]
      end

      it 'only observes two levels of nesting' do
        pe = create :liquid_partial, title: 'e', content: '<p>;)</p>{{ plugins.e[ref] }}'
        pd = create :liquid_partial, title: 'd', content: '<p>{% include "e" %}</p>{{ plugins.d[ref] }}'
        pc = create :liquid_partial, title: 'c', content: '<p>{% include "d" %}</p>{{ plugins.c[ref] }}'
        pb = create :liquid_partial, title: 'b', content: '<p>{% include "c" %}</p>{{ plugins.b[ref] }}'
        pa = create :liquid_partial, title: 'a', content: '<p>{% include "b" %}</p>{{ plugins.a[ref] }}'
        expect(pa.plugin_refs).to eq [['a', nil], ['b', nil], ['c', nil]]
      end
    end

  end

  describe "missing_partials" do

    it "filters out none if none exist" do
      nonexistent = ['fake', 'not_a_real_partial', 'seriouslyyy']
      expect(LiquidPartial.missing_partials(nonexistent)).to eq nonexistent
    end

    it "filters out all if none exist" do
      p1 = create :liquid_partial
      p2 = create :liquid_partial
      p3 = create :liquid_partial
      expect(LiquidPartial.missing_partials([p1, p2, p3].map(&:title))).to eq []
    end

    it "filters out only nonexistent" do
      p1 = create :liquid_partial
      p2 = create :liquid_partial
      expect(LiquidPartial.missing_partials([p1.title, 'lies', p2.title])).to eq ['lies']
    end

  end


end
