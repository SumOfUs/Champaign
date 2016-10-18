# frozen_string_literal: true
require 'rails_helper'

describe PageCloner do
  let!(:tag) { create(:tag) }
  let(:campaign) { create(:campaign) }
  let!(:petition_partial) { create :liquid_partial, title: 'petition', content: '{{ plugins.petition[ref] }}' }
  let!(:thermo_partial) { create :liquid_partial, title: 'thermometer', content: '{{ plugins.thermometer[ref] }}' }
  let(:liquid_layout) { create(:liquid_layout, :default) }
  let(:page) do
    create(
      :page,
      tags: [tag],
      campaign: campaign,
      liquid_layout: liquid_layout,
      title: 'foo bar',
      content: 'Foo Bar',
      action_count: 12_345
    )
  end
  let!(:link) { create(:link, page: page) }

  subject(:cloned_page) { PageCloner.clone(page).reload }

  it 'clones page' do
    expect(cloned_page.id).not_to eq(page.id)
  end

  it 'clones links' do
    expect(cloned_page.links).not_to eq(page.links)
    expect(cloned_page.links.size).to eq(1)
  end

  it 'clones tag associations' do
    expect(cloned_page.tags).to eq(page.tags)
    expect(cloned_page.tags.size).to eq(1)
  end

  it 'associates with the same language' do
    expect(cloned_page.language).to eq(page.language)
    expect(cloned_page.language).not_to be_nil
  end

  it 'associates with the same campaign' do
    expect(cloned_page.campaign).to eq(campaign)
  end

  it 'duplicates content' do
    expect(cloned_page.content).to eq('Foo Bar')
  end

  it 'sets the new pages action_count to 0' do
    expect(page.action_count).not_to eq(0)
    expect(cloned_page.action_count).to eq(0)
  end

  describe 'title and slug' do
    context 'no title is passed in' do
      it 'clones title' do
        expect(cloned_page.title).to eq('foo bar')
      end

      it 'clones slug with appended count' do
        expect(cloned_page.slug).to eq('foo-bar-1')
      end
    end

    context 'new title passed in' do
      subject(:cloned_page) { PageCloner.clone(page, 'The English Patient') }

      it 'assigns new title' do
        expect(cloned_page.title).to eq('The English Patient')
        expect(cloned_page.slug).to  eq('the-english-patient')
      end
    end
  end

  context 'images' do
    let!(:image) { create(:image, page: page) }
    let!(:primary_image) { create(:image, page: page) }

    before do
      page.update(primary_image: primary_image)
    end

    it 'clones images' do
      expect(cloned_page.images.count).to eq(page.reload.images.count)
    end

    it 'associates primary image' do
      expect(page.primary_image).to eq(primary_image)
      expect(cloned_page.primary_image).not_to eq(primary_image)
    end
  end

  context 'plugins' do
    let(:custom_field) { create(:form_element, name: 'foo_bar') }
    let(:petition) { page.plugins.select { |p| p.class == Plugins::Petition }.first }

    before do
      link.destroy! # create the conditions that incited the bug previously
      petition.form.form_elements << custom_field
      petition.form.save
    end

    def get_plugin(type)
      [page.plugins.select { |plugin| plugin.is_a?(type) }.first,
       cloned_page.plugins.select { |plugin| plugin.is_a?(type) }.first]
    end

    it 'has the plugins indicated by the liquid layout before the clone' do
      expect(page.plugins.count).to eq 2
      expect(page.plugins.map(&:class)).to match_array([Plugins::Petition, Plugins::Thermometer])
    end

    it 'clones plugins' do
      expect(cloned_page.plugins.count).to eq(2)
      expect(cloned_page.plugins).not_to match(page.plugins)
    end

    it 'clones petition' do
      original, cloned = get_plugin(Plugins::Petition)
      expect(cloned).not_to eq(original)
    end

    it 'clones thermometer' do
      original, cloned = get_plugin(Plugins::Thermometer)
      expect(cloned).not_to eq(original)
    end

    context 'forms' do
      let(:form) { petition.form }
      let(:cloned_form) { cloned_page.plugins.first.form }

      it 'clones form' do
        expect(cloned_form).not_to eq(form)
        expect(cloned_form).to be_a(Form)
      end

      it 'clones form elements' do
        expect(cloned_form.form_elements).not_to match_array(form.form_elements)

        expect(
          cloned_form.form_elements.map(&:name)
        ).to include('action_textentry_foo_bar')
      end
    end
  end
end
