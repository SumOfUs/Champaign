require 'rails_helper'

describe PageCloner do
  let!(:tag)  { create(:tag) }
  let(:campaign) { create(:campaign) }
  let(:page)  { create(:page, tags: [tag], campaign: campaign) }
  let!(:link) { create(:link, page: page) }

  subject(:cloned_page) { PageCloner.clone!(page) }

  it 'clones page' do
    expect(cloned_page.id).not_to eq(page.id)
  end

  it 'clones links' do
    expect(cloned_page.links).not_to eq(page.links)
    expect(cloned_page.links.count).to eq(1)
  end

  it 'clones tag associations' do
    expect(cloned_page.tags).to eq(page.tags)
    expect(cloned_page.tags.count).to eq(1)
  end

  it 'associates with the same language' do
    expect(cloned_page.language).to eq(page.language)
    expect(cloned_page.language).not_to be_nil
  end

  it 'associates with the same campaign' do
    expect(cloned_page.campaign).to eq(campaign)
  end

  describe 'title and slug' do
    # TODO: not sure what's best here.

    it 'appends timestamp to title' do
      expect(cloned_page.title).to match(/\d{4}-\d{1,2}-\d{1,2}/)
    end
  end

  context 'images' do
    let!(:image) { create(:image, page: page) }
    let!(:primary_image) { create(:image, page: page) }

    before do
      page.update(primary_image: primary_image)
    end

    it 'clones image' do
      expect(cloned_page.images.first).not_to eq(page.images.first)
    end

    it 'clones primary image' do
      expect(page.primary_image).to eq(primary_image)
      expect(cloned_page.primary_image).not_to eq(primary_image)
    end
  end

  context 'plugins' do
    let(:custom_field) { create(:form_element, name: "foo_bar") }
    let!(:petition)    { create(:plugins_petition, page: page) }
    let!(:thermometer) { create(:plugins_thermometer, page: page) }
    let!(:fundraiser)  { create(:plugins_fundraiser, page: page) }

    before do
      petition.form.form_elements << custom_field
      petition.form.save
    end

    def get_plugin(type)
      [
        page.plugins.select{|plugin| plugin.is_a?(type)}.first,
        cloned_page.plugins.select{|plugin| plugin.is_a?(type)}.first
      ]
    end

    it 'clones petition' do
      original, cloned = get_plugin(Plugins::Petition)
      expect(cloned).not_to eq(original)
    end

    it 'clones fundraiser' do
      original, cloned = get_plugin(Plugins::Fundraiser)
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
          cloned_form.form_elements.map{|e| e.name }
        ).to include('action_textentry_foo_bar')
      end
    end
  end
end
