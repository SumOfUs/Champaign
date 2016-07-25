require 'rails_helper'

describe Page do

  let(:english)          { create :language }
  let!(:follow_up_layout) { create :liquid_layout, title: 'Follow up layout' }
  let!(:liquid_layout)    { create :liquid_layout, title: 'Liquid layout', default_follow_up_layout: follow_up_layout }
  let(:page)             { create :page, liquid_layout: liquid_layout, follow_up_liquid_layout: follow_up_layout  }

  let(:page_params) { attributes_for :page, liquid_layout_id: liquid_layout.id }
  let(:image_file) { File.new(Rails.root.join('spec','fixtures','test-image.gif')) }
  let(:image_1) { Image.create!(content: image_file) }
  let(:image_2) { Image.create!(content: image_file) }
  let(:image_3) { Image.create!(content: image_file) }

  subject { page }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :slug }
  it { is_expected.to respond_to :publish_status }
  it { is_expected.to respond_to :featured }
  it { is_expected.to respond_to :tags }
  it { is_expected.to respond_to :pages_tags }
  it { is_expected.to respond_to :campaign }
  it { is_expected.to respond_to :liquid_layout }
  it { is_expected.to respond_to :follow_up_liquid_layout }
  it { is_expected.to respond_to :follow_up_page }
  it { is_expected.to respond_to :follow_up_plan }
  it { is_expected.to respond_to :with_liquid? }
  it { is_expected.to respond_to :with_page? }
  it { is_expected.to respond_to :primary_image }
  it { is_expected.to respond_to :plugins }
  it { is_expected.to respond_to :shares }
  it { is_expected.to respond_to :action_count }
  it { is_expected.to respond_to :tag_names }
  it { is_expected.to respond_to :plugin_names }
  it { is_expected.to respond_to :meta_tags }
  it { is_expected.to respond_to :javascript }

  it { is_expected.not_to respond_to :secondary_liquid_layout }

  describe 'tags' do
    before(:all) do
      3.times do create :tag end
    end

    it 'should be a reciprocal many-to-many relationship' do
      page = create :page, tags: Tag.last(2)
      expect(page.tags).to match_array Tag.last(2)
      expect(Tag.last.pages).to match_array [page]
      expect(Tag.first.pages).to match_array []
    end

    it 'reflects assigned tags in the tag_names property' do
      page = create :page, tags: Tag.last(2)
      tag_array = page.tags.map { |tag| tag.name.downcase }
      expect(page.tag_names).to match_array(tag_array)
    end

    describe 'create' do

      after :each do
        page = Page.new page_params
        expect{ page.save! }.to change{ PagesTag.count }.by 2
        expect(page.tags).to match_array(Tag.last(2))
      end

      it 'should create the many-to-many association with int ids' do
        page_params[:tag_ids] = Tag.last(2).map(&:id).map(&:to_i)
      end

      it 'should create the many-to-many association with string ids' do
        page_params[:tag_ids] = Tag.last(2).map(&:id).map(&:to_s)
      end
    end

    describe 'destroy' do

      before :each do
        @page = create :page, language: english, tag_ids: Tag.last(2).map(&:id)
      end

      it 'should destroy the page' do
        expect{ @page.destroy }.to change{ Page.count }.by(-1)
      end

      it 'should destroy the join table records' do
        expect{ @page.destroy }.to change{ PagesTag.count }.by(-2)
      end

      it 'should not destroy the tag' do
        expect{ @page.destroy }.to change{ Tag.count }.by(0)
      end
    end

    describe 'update' do

      before :each do
        @page = create :page, language: english, tag_ids: Tag.last(2).map(&:id)
        @new_ids = Tag.first.id
      end

      it 'should update both sides of the relationship' do
        @page.update! tag_ids: @new_ids
        expect(@page.tags).to eq [Tag.first]
        expect(Tag.first.pages).to eq [@page]
        expect(Tag.last.pages).to eq []
      end

      it 'should destroy the old join table records and make a new one' do
        expect{ @page.update! tag_ids: @new_ids }.to change{ PagesTag.count }.by(-1)
      end
    end
  end

  describe 'campaigns' do

    before :each do
      3.times do create :campaign end
    end

    describe 'create' do

      after :each do
        page = Page.new page_params
        expect{ page.save! }.to change{ Campaign.count }.by 0
        expect(page.campaign).to eq Campaign.last
      end

      it 'should create the many-to-many association with int ids' do
        page_params[:campaign_id] = Campaign.last.id.to_i
      end

      it 'should create the many-to-many association with string ids' do
        page_params[:campaign_id] = Campaign.last.id.to_s
      end
    end
  end

  describe 'language' do
    it 'should not be required' do
      page.language = nil
      expect(page).to be_valid
    end
  end

  describe 'images' do
    it 'get deleted when the page is deleted' do
      page.images = [image_1, image_2]
      page.save!
      expect{ page.destroy }.to change{ Image.count }.by -2
    end
  end

  describe 'link' do
    it 'get deleted when the page is deleted' do
      link_1 = create :link
      link_2 = create :link
      page.links = [link_1, link_2]
      page.save!
      expect{ page.destroy }.to change{ Link.count }.by -2
    end
  end

  describe 'liquid_layout' do

    let(:switcher) { instance_double(PagePluginSwitcher, switch: nil)}
    let(:other_liquid_layout) { create :liquid_layout, title: 'Other liquid layout' }

    before :each do
      allow(PagePluginSwitcher).to receive(:new).and_return(switcher)
    end

    describe 'valid' do

      before :each do
        expect(page).to be_valid
        expect(page).to be_persisted
        expect(page.follow_up_plan).to eq 'with_liquid'
      end

      it 'switches the layout plugins if layout changed' do
        page.liquid_layout = other_liquid_layout
        expect(PagePluginSwitcher).to receive(:new)
        expect(switcher).to receive(:switch).with(other_liquid_layout, follow_up_layout)
        expect(page.save).to eq true
      end

      it 'does not switch the layout plugins if no layouts or plan changed' do
        page.title = "just changin the title here"
        expect(switcher).not_to receive(:switch)
        expect(page.save).to eq true
      end

      it 'switches if the follow up layout changed' do
        page.follow_up_liquid_layout = other_liquid_layout
        expect(PagePluginSwitcher).to receive(:new)
        expect(switcher).to receive(:switch).with(liquid_layout, other_liquid_layout)
        expect(page.save).to eq true
      end

      it 'switches if the follow up plan changed' do
        page.follow_up_plan = 'with_page'
        expect(PagePluginSwitcher).to receive(:new)
        expect(switcher).to receive(:switch).with(liquid_layout, nil)
        expect(page.save).to eq true
      end

      it 'switches if all the layouts and plan changed' do
        page.follow_up_liquid_layout = other_liquid_layout
        page.liquid_layout = other_liquid_layout
        page.follow_up_plan = 'with_page'
        expect(PagePluginSwitcher).to receive(:new)
        expect(switcher).to receive(:switch).with(other_liquid_layout, nil)
        expect(page.save).to eq true
      end
    end

    describe 'invalid' do
      it 'does not switch the layout plugins even if layout is changed' do
        page.title = nil
        page.liquid_layout = other_liquid_layout
        expect(switcher).not_to receive(:switch)
        expect(page.save).to eq false
      end
    end
  end

  describe 'primary image' do

    before :each do
      page.images = [image_1, image_2]
      page.primary_image = image_2
      page.save!
    end

    it 'finds the image' do
      expect(page.primary_image).to eq image_2
    end

    it 'cannot be set to an image that doesnt belong to the page' do
      expect(page).to be_valid
      page.primary_image = image_3
      expect(page).to be_invalid
    end

    it 'gets set to nil if the image is deleted' do
      expect(page.primary_image).to eq image_2
      expect{ image_2.destroy }.to change{ Image.count }.by(-1)
      expect(page.reload.primary_image).to eq nil
    end
  end

  describe 'shares' do
    it 'can find a twitter variant' do
      twitter_share = create :share_twitter, page: page
      expect(page.shares).to eq [twitter_share]
    end

    it 'can find a facebook variant' do
      facebook_share = create :share_facebook, page: page
      expect(page.shares).to eq [facebook_share]
    end

    it 'can find a email variant' do
      email_share = create :share_email, page: page
      expect(page.shares).to eq [email_share]
    end

    it 'returns empty array if none exist' do
      expect(page.shares).to eq []
    end

    it 'can find multiple of each type' do
      existing_page = create(:page)

      create :share_twitter, page: nil
      create :share_twitter, page: nil

      t1 = create :share_twitter, page: page

      f1 = facebook_share = create :share_facebook, page: page
      f2 = facebook_share = create :share_facebook, page: page
      f3 = facebook_share = create :share_facebook, page: page
      f4 = facebook_share = create :share_facebook, page: existing_page

      create :share_email, page: nil

      e1 = create :share_email, page: page
      e3 = create :share_email, page: existing_page
      e2 = create :share_email, page: page

      expect(page.shares).to          match_array [t1, f1, f2, f3, e1, e2]
      expect(existing_page.shares).to match_array [f4, e3]
    end
  end

  describe 'action_count' do

    it 'defaults to 0' do
      expect(Page.new.action_count).to eq 0
    end
  end

  describe '#dup' do
    let(:image) { create(:image, page: page) }

    before do
      page.update(primary_image: image)
    end

    subject{ page.dup }

    it 'sets slug to nil' do
      expect(page.slug).not_to be_nil
      expect(subject.slug).to be_nil
    end

    it 'sets primary_image to nil' do
      expect(page.primary_image).to eq(image)
      expect(subject.primary_image).to be_nil
    end
  end

  describe 'friendly_id' do
    let!(:page) { create(:page, title: 'simple slug') }

    it 'generates slug' do
      expect(page.friendly_id).to eq('simple-slug')
      expect(page.slug).to        eq('simple-slug')
    end

    context 'finder' do
      it 'finds by slug' do
        expect(Page.find('simple-slug')).to eq(page)
      end

      it 'finds by id' do
        expect(Page.find(page.id)).to eq(page)
      end

      it 'finds using friendly.find' do
        expect(Page.friendly.find('simple-slug')).to eq(page)
        expect(Page.friendly.find(page.id)).to       eq(page)
      end
    end

    context 'duplicate title' do
      it 'appends count to slug' do
        other_page = create(:page, title: 'simple slug')
        expect(other_page.slug).to eq('simple-slug-1')
      end
    end

    context 'updating title' do
      before do
        page.update(title: 'Complex Slug', slug: nil)
        page.reload
      end

      it 'updates slug' do
        expect(page.title).to       eq('Complex Slug')
        expect(page.friendly_id).to eq('complex-slug')
      end
    end
  end

  describe 'follow_up_plan' do
    it 'defaults to :with_liquid' do
      new_page = create :page
      expect(new_page.follow_up_plan).to eq 'with_liquid'
    end
  end

  describe 'plugins' do
    it 'correctly lists the names of plugins' do
      page = create :page
      [create(:plugins_petition, page: page), create(:plugins_fundraiser, page: page), create(:plugins_thermometer, page: page)]
      plugin_names = %w(petition fundraiser thermometer)
      expect(page.plugin_names).to match_array(plugin_names)
    end
  end

  describe 'scopes' do
    describe 'published' do
      let!(:published_page) { create(:page, publish_status: 'published') }
      let!(:page) { create(:page, publish_status: 'unpublished') }

      it 'returns published pages' do
        expect(Page.published).to eq([published_page])
      end
    end

    describe 'language' do
      let!(:en_page) { create(:page, language: create(:language, :english)) }
      let!(:fr_page) { create(:page, language: create(:language, :french)) }

      it 'finds with matching language' do
        expect(Page.language('en')).to eq([en_page])
        expect(Page.language('fr')).to eq([fr_page])
      end

      it 'returns all if no language code is passed' do
        expect(Page.language(nil)).to match_array([en_page, fr_page])
      end
    end

    describe 'featured_only' do
      let!(:featured_page) { create(:page, featured: true) }
      let!(:page) { create(:page, featured: false) }

      it 'finds featured' do
        expect(Page.featured).to match([featured_page])
      end
    end
  end
end

