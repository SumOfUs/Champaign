# frozen_string_literal: true

# == Schema Information
#
# Table name: liquid_partials
#
#  id         :integer          not null, primary key
#  title      :string
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe LiquidPartial do
  let(:partial) { create(:liquid_partial) }

  subject { partial }

  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :content }
  it { is_expected.to respond_to :plugin_name }
  it { is_expected.to respond_to :partial_names }
  it { is_expected.to respond_to :partial_refs }

  it { is_expected.not_to respond_to :one_plugin }

  describe 'is valid' do
    it 'with factory settings' do
      expect(partial).to be_valid
    end

    it 'with multiple references to the same plugin' do
      partial.content = "<div>{{ plugins.petition[ref].text }}</div>
                         <div>{{ plugins.petition[ref].wink }}</div>"

      expect(partial).to be_valid
    end

    it 'with a reference to a partial that does exist' do
      create :liquid_partial, title: 'existent'
      partial.content = "<div>{% include 'existent' %}</div>"
      expect(partial).to be_valid
    end
  end

  describe 'is invalid' do
    it 'with a blank title' do
      partial.title = ' '

      expect(partial).to be_invalid
    end

    it 'with a blank content' do
      partial.content = ' '

      expect(partial).to be_invalid
    end

    it 'with multiple references to different plugins' do
      partial.content = "<div>{{ plugins.petition[ref].text }}</div>
                         <div>{{ plugins.thermometer[ref].wink }}</div>"

      expect(partial).to be_invalid
    end

    it "with a reference to a partial that doesn't exist" do
      partial.content = "<div>{% include 'nonexistent' %}</div>"

      expect(partial).to be_invalid
    end
  end

  describe 'plugin_refs' do
    describe 'without nested partials' do
      it 'returns its own plugin with the passed ref' do
        pa = create :liquid_partial, title: 'a', content: '<p>{{ plugins.my_plugin[ref] }}</p>'
        expect(pa.plugin_refs(ref: 'my_ref')).to eq [%w[my_plugin my_ref]]
      end

      it 'returns empty array if no plugins' do
        pa = create :liquid_partial, title: 'a', content: '<p>Fire in the hole!</p>'
        expect(pa.plugin_refs(ref: 'my_ref')).to eq []
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
        expect(pa.plugin_refs).to match_array [%w[e lol], ['e', nil]]
      end

      it 'with a tree of partials with different plugins' do
        pe = create :liquid_partial, title: 'e', content: '<p>{{ plugins.e[ref] }}</p>'
        pd = create :liquid_partial, title: 'd', content: '<p>{{ plugins.d[ref] }}</p>'
        pc = create :liquid_partial, title: 'c', content: '<p>{% include "e" %}{% include "d" %} {{ plugins.c[ref] }}</p>'
        pb = create :liquid_partial, title: 'b', content: '<p>{% include "e", ref: "lol" %} {{ plugins.b[ref] }}</p>'
        pa = create :liquid_partial, title: 'a', content: '<p>{% include "b", ref: "heyy" %}</p>{% include "c" %} {{ plugins.a[ref] }}'
        expect(pa.plugin_refs).to match_array [['a', nil], %w[b heyy], ['c', nil], ['d', nil], ['e', nil], %w[e lol]]
      end

      it 'with multiple partials with the same plugin' do
        pc = create :liquid_partial, title: 'c', content: '<p>{{ plugins.my_plugin[ref] }}</p>'
        pb = create :liquid_partial, title: 'b', content: '<p>{{ plugins.my_plugin[ref] }}</p>'
        pa = create :liquid_partial, title: 'a', content: '<p>{% include "b", ref: "yay" %}</p>{% include "c" %}{{ plugins.my_plugin[ref] }}'
        expect(pa.plugin_refs).to match_array [%w[my_plugin yay], ['my_plugin', nil]]
        expect(pa.plugin_refs(ref: 'yay')).to match_array [%w[my_plugin yay], ['my_plugin', nil]]
        expect(pa.plugin_refs(ref: 'nae')).to match_array [%w[my_plugin yay], ['my_plugin', nil], %w[my_plugin nae]]
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

  describe 'missing_partials' do
    it 'filters out none if none exist' do
      nonexistent = %w[fake not_a_real_partial seriouslyyy]
      expect(LiquidPartial.missing_partials(nonexistent)).to eq nonexistent
    end

    it 'filters out all if none exist' do
      p1 = create :liquid_partial
      p2 = create :liquid_partial
      p3 = create :liquid_partial
      expect(LiquidPartial.missing_partials([p1, p2, p3].map(&:title))).to eq []
    end

    it 'filters out only nonexistent' do
      p1 = create :liquid_partial
      p2 = create :liquid_partial
      expect(LiquidPartial.missing_partials([p1.title, 'lies', p2.title])).to eq ['lies']
    end
  end

  describe 'Cache' do
    let!(:record) { create(:liquid_partial) }

    context 'after save' do
      it 'invalidates cache' do
        expect(LiquidRenderer::Cache).to receive(:invalidate)
        record.save
      end
    end

    context 'after destroy' do
      it 'invalidates cache' do
        expect(LiquidRenderer::Cache).to receive(:invalidate)
        record.destroy
      end
    end
  end
end
