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
      :featured,
      tags: [tag],
      campaign: campaign,
      liquid_layout: liquid_layout,
      title: 'foo bar',
      content: 'Foo Bar',
      action_count: 12_345
    )
  end
  let!(:image) { create(:image, page: page, id: 123) }
  let!(:fb_share) do
    create(:share_facebook,
           page: page,
           description: 'facebook share {LINK}',
           title: 'share',
           image_id: image.id)
  end
  let!(:tw_share) do
    create(:share_twitter,
           page: page,
           description: 'twitter share {LINK}')
  end
  let!(:email_share) do
    create(:share_email,
           page: page,
           subject: 'forward this email',
           body: 'They are on it! {LINK}')
  end
  let!(:link) { create(:link, page: page) }

  subject(:cloned_page) do
    @title ||= nil
    @language_id ||= nil
    @override_forms ||= nil
    VCR.use_cassette('page_cloner_share_success') do
      PageCloner.clone(page, @title, @language_id, @override_forms).reload
    end
  end

  it 'clones page' do
    expect(cloned_page.id).not_to eq(page.id)
  end

  it 'clones links' do
    expect(cloned_page.links).not_to eq(page.links)
    expect(cloned_page.links.size).to eq(1)
  end

  it 'clones shares' do
    expect(cloned_page.shares).to_not eq(page.shares)
    expect(cloned_page.shares.size).to eq(page.shares.size)
  end

  it 'clones facebook shares' do
    fb_shares = cloned_page.shares.select { |s| s.class.name.downcase.demodulize == 'facebook' }
    expect(fb_shares.length).to eq 1
    fb_shares.each do |share|
      expect(share.id).to_not eq(fb_share.id)
      expect(share.description).to eq('facebook share {LINK}')
      expect(share.title).to eq('share')
      expect(share.image_id).not_to eq(123)
      expect(cloned_page.images.map(&:id)).to include(share.image_id)
    end
  end

  it 'clones twitter shares' do
    tw_shares = cloned_page.shares.select { |s| s.class.name.downcase.demodulize == 'twitter' }
    expect(tw_shares.length).to eq 1
    tw_shares.each do |share|
      expect(share.id).to_not eq(tw_share.id)
      expect(share.description).to eq('twitter share {LINK}')
    end
  end

  it 'clones email shares' do
    em_shares = cloned_page.shares.select { |s| s.class.name.downcase.demodulize == 'email' }
    expect(em_shares.length).to eq 1
    em_shares.each do |share|
      expect(share.id).to_not eq(email_share.id)
      expect(share.subject).to eq('forward this email')
      expect(share.body).to eq('They are on it! {LINK}')
    end
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

  it 'updates the language when language_id is passed' do
    @language_id = create(:language, :french).id
    expect(cloned_page.language_id).to eq(@language_id)
    expect(cloned_page.language.code).to eq 'fr'
  end

  it 'sets the new pages action_count to 0' do
    expect(page.action_count).not_to eq(0)
    expect(cloned_page.action_count).to eq(0)
  end

  it 'unfeatures page' do
    expect(page.featured).to be true
    expect(cloned_page.featured).to be false
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
      subject(:cloned_page) do
        VCR.use_cassette('page_cloner_share_success') do
          PageCloner.clone(page, 'The English Patient')
        end
      end

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
      expect { cloned_page }.to change { Image.count }.by 2
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
        expect(cloned_form.form_elements.map(&:name)).to match_array(form.form_elements.map(&:name))
      end

      context 'when override_forms is passed' do
        before :each do
          @override_forms = true
        end

        it 'with a language_id it creates a new form with the same language' do
          @language_id = create(:language, :german).id
          expect { cloned_page }.to change { Form.count }.by 2 # it also creates the german master form
          expect(cloned_form.form_elements.map(&:name)).not_to match_array(form.form_elements.map(&:name))
          expect(cloned_form.form_elements.map(&:label)).to include('VOLLSTÄNDIGER NAME')
        end

        it 'without a language_id' do
          expect { cloned_page }.to change { Form.count }.by 1
          expect(cloned_form.form_elements.map(&:name)).not_to match_array(form.form_elements.map(&:name))
        end
      end
    end
  end
end
