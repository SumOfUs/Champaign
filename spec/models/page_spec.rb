require 'rails_helper'

describe Page do

  let(:english) { create :language }
  let(:liquid_layout) { create :liquid_layout }
  let!(:simple_page) { create :page, liquid_layout: liquid_layout, slug: 'simple_slug' }
  let(:existing_page) { create :page }
  let(:page_params) { attributes_for :page, liquid_layout_id: liquid_layout.id }
  let(:image_file) { File.new(Rails.root.join('spec','fixtures','test-image.gif')) }
  let(:image_1) { Image.create!(content: image_file) }
  let(:image_2) { Image.create!(content: image_file) }
  let(:image_3) { Image.create!(content: image_file) }

  subject { simple_page }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :slug }
  it { is_expected.to respond_to :active }
  it { is_expected.to respond_to :featured }
  it { is_expected.to respond_to :tags }
  it { is_expected.to respond_to :pages_tags }
  it { is_expected.to respond_to :campaign }
  it { is_expected.to respond_to :liquid_layout }
  it { is_expected.to respond_to :secondary_liquid_layout }
  it { is_expected.to respond_to :primary_image }
  it { is_expected.to respond_to :plugins }
  it { is_expected.to respond_to :shares }
  it { is_expected.to respond_to :action_count }

  describe 'tags' do

    before :each do
      3.times do create :tag end
    end

    it 'should be a reciprocal many-to-many relationship' do
      page = Page.create!(page_params.merge({tag_ids: Tag.last(2).map(&:id)}))
      expect(page.tags).to match_array Tag.last(2)
      expect(Tag.last.pages).to match_array [page]
      expect(Tag.first.pages).to match_array []
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
        expect{ @page.destroy }.to change{ Page.count }.by -1
      end

      it 'should destroy the join table records' do
        expect{ @page.destroy }.to change{ PagesTag.count }.by -2
      end

      it 'should not destroy the tag' do
        expect{ @page.destroy }.to change{ Tag.count }.by 0
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
        expect{ @page.update! tag_ids: @new_ids }.to change{ PagesTag.count }.by -1
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
      simple_page.language = nil
      expect(simple_page).to be_valid
    end
  end

  describe 'images' do
    it 'get deleted when the page is deleted' do
      simple_page.images = [image_1, image_2]
      simple_page.save!
      expect{ simple_page.destroy }.to change{ Image.count }.by -2
    end
  end

  describe 'link' do
    it 'get deleted when the page is deleted' do
      link_1 = create :link
      link_2 = create :link
      simple_page.links = [link_1, link_2]
      simple_page.save!
      expect{ simple_page.destroy }.to change{ Link.count }.by -2
    end
  end

  describe 'liquid_layout' do

    let(:switcher) { instance_double(PagePluginSwitcher, switch: nil)}
    let(:other_liquid_layout) { create :liquid_layout }

    before :each do
      allow(PagePluginSwitcher).to receive(:new).and_return(switcher)
    end

    describe 'valid' do

      before :each do
        expect(simple_page).to be_valid
        expect(simple_page).to be_persisted
      end

      it 'switches the layout plugins if layout changed' do
        simple_page.liquid_layout = other_liquid_layout
        expect(PagePluginSwitcher).to receive(:new)
        expect(switcher).to receive(:switch).with(other_liquid_layout)
        expect(simple_page.save).to eq true
      end

      it 'does not switch the layout plugins if layout unchanged' do
        simple_page.title = "just changin the title here"
        expect(switcher).not_to receive(:switch)
        expect(simple_page.save).to eq true
      end
    end

    describe 'invalid' do
      it 'does not switch the layout plugins even if layout is changed' do
        simple_page.title = nil
        simple_page.liquid_layout = other_liquid_layout
        expect(switcher).not_to receive(:switch)
        expect(simple_page.save).to eq false
      end
    end
  end

  describe 'primary image' do

    before :each do
      simple_page.images = [image_1, image_2]
      simple_page.primary_image = image_2
      simple_page.save!
    end

    it 'finds the image' do
      expect(simple_page.primary_image).to eq image_2
    end

    it 'cannot be set to an image that doesnt belong to the page' do
      expect(simple_page).to be_valid
      simple_page.primary_image = image_3
      expect(simple_page).to be_invalid
    end

    it 'gets set to nil if the image is deleted' do
      expect(simple_page.primary_image).to eq image_2
      expect{ image_2.destroy }.to change{ Image.count }.by(-1)
      expect(simple_page.reload.primary_image).to eq nil
    end
  end

  describe 'shares' do

    it 'can find a twitter variant' do
      twitter_share = create :share_twitter, page: simple_page
      expect(simple_page.shares).to eq [twitter_share]
    end

    it 'can find a facebook variant' do
      facebook_share = create :share_facebook, page: simple_page
      expect(simple_page.shares).to eq [facebook_share]
    end

    it 'can find a email variant' do
      email_share = create :share_email, page: simple_page
      expect(simple_page.shares).to eq [email_share]
    end

    it 'returns empty array if none exist' do
      expect(simple_page.shares).to eq []
    end

    it 'can find multiple of each type' do
      t1 = create :share_twitter, page: simple_page
      t2 = create :share_twitter, page: nil
      t3 = create :share_twitter, page: nil
      f1 = facebook_share = create :share_facebook, page: simple_page
      f2 = facebook_share = create :share_facebook, page: simple_page
      f3 = facebook_share = create :share_facebook, page: simple_page
      f4 = facebook_share = create :share_facebook, page: existing_page
      e1 = create :share_email, page: simple_page
      e4 = create :share_email, page: nil
      e3 = create :share_email, page: existing_page
      e2 = create :share_email, page: simple_page
      expect(simple_page.shares).to match_array [t1, f1, f2, f3, e1, e2]
      expect(existing_page.shares).to match_array [f4, e3]
    end
  end

  describe 'action_count' do

    it 'defaults to 0' do
      expect(Page.new.action_count).to eq 0
    end
  end

  describe 'find by slug' do
    it 'finds a page by its slug' do
      expect(Page.find('simple_slug')).to eq simple_page
    end
    it 'finds a page by id' do
      expect(Page.find(simple_page.id)).to eq simple_page
    end
  end
end

