require 'rails_helper'

describe Page do

  let(:english) { create :language }
  let(:liquid_layout) { create :liquid_layout }
  let(:simple_page) { create :page, liquid_layout: liquid_layout }
  let(:existing_page) { create :page }
  let(:page_params) { attributes_for :page, liquid_layout_id: liquid_layout.id }

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
  it { is_expected.to respond_to :plugins }

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
end

