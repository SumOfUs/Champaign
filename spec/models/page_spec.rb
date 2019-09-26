# frozen_string_literal: true

# == Schema Information
#
# Table name: pages
#
#  id                         :integer          not null, primary key
#  action_count               :integer          default(0)
#  ak_donation_resource_uri   :string
#  ak_petition_resource_uri   :string
#  allow_duplicate_actions    :boolean          default(FALSE)
#  canonical_url              :string
#  compiled_html              :text
#  content                    :text             default("")
#  enforce_styles             :boolean          default(FALSE), not null
#  featured                   :boolean          default(FALSE)
#  follow_up_plan             :integer          default("with_liquid"), not null
#  fundraising_goal           :decimal(10, 2)   default(0.0)
#  javascript                 :text
#  messages                   :text
#  meta_description           :string
#  meta_tags                  :string
#  notes                      :text
#  optimizely_status          :integer          default("optimizely_enabled"), not null
#  publish_actions            :integer          default("secure"), not null
#  publish_status             :integer          default("unpublished"), not null
#  slug                       :string           not null
#  status                     :string           default("pending")
#  title                      :string           not null
#  total_donations            :decimal(10, 2)   default(0.0)
#  created_at                 :datetime
#  updated_at                 :datetime
#  campaign_id                :integer
#  follow_up_liquid_layout_id :integer
#  follow_up_page_id          :integer
#  language_id                :integer
#  liquid_layout_id           :integer
#  primary_image_id           :integer
#
# Indexes
#
#  index_pages_on_campaign_id                 (campaign_id)
#  index_pages_on_follow_up_liquid_layout_id  (follow_up_liquid_layout_id)
#  index_pages_on_follow_up_page_id           (follow_up_page_id)
#  index_pages_on_liquid_layout_id            (liquid_layout_id)
#  index_pages_on_primary_image_id            (primary_image_id)
#  index_pages_on_publish_status              (publish_status)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (follow_up_liquid_layout_id => liquid_layouts.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (liquid_layout_id => liquid_layouts.id)
#  fk_rails_...  (primary_image_id => images.id)
#

require 'rails_helper'

describe Page do
  let(:english) { create :language }
  let!(:follow_up_layout) { create :liquid_layout, title: 'Follow up layout' }
  let!(:liquid_layout)    { create :liquid_layout, title: 'Liquid layout', default_follow_up_layout: follow_up_layout }
  let(:page) { create :page, liquid_layout: liquid_layout, follow_up_liquid_layout: follow_up_layout }

  let(:page_params) { attributes_for :page, liquid_layout_id: liquid_layout.id }
  let(:image_file) { File.new(Rails.root.join('spec', 'fixtures', 'test-image.gif')) }
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
  it { is_expected.to respond_to :campaign_action_count }
  it { is_expected.to respond_to :tag_names }
  it { is_expected.to respond_to :plugin_names }
  it { is_expected.to respond_to :javascript }
  it { is_expected.to respond_to :canonical_url }
  it { is_expected.to respond_to :optimizely_status }
  it { is_expected.to respond_to :optimizely_enabled? }
  it { is_expected.to respond_to :optimizely_disabled? }
  it { is_expected.to respond_to :optimizely_enabled! }
  it { is_expected.to respond_to :optimizely_disabled! }

  it { is_expected.not_to respond_to :secondary_liquid_layout }

  describe 'tags' do
    before(:all) do
      3.times { create :tag }
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
        expect { page.save! }.to change { PagesTag.count }.by 2
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
        expect { @page.destroy }.to change { Page.count }.by(-1)
      end

      it 'should destroy the join table records' do
        expect { @page.destroy }.to change { PagesTag.count }.by(-2)
      end

      it 'should not destroy the tag' do
        expect { @page.destroy }.to change { Tag.count }.by(0)
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
        expect { @page.update! tag_ids: @new_ids }.to change { PagesTag.count }.by(-1)
      end
    end
  end

  describe 'campaigns' do
    before :each do
      3.times { create :campaign }
    end

    describe 'create' do
      after :each do
        page = Page.new page_params
        expect { page.save! }.to change { Campaign.count }.by 0
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
      expect { page.destroy }.to change { Image.count }.by -2
    end
  end

  describe 'link' do
    it 'get deleted when the page is deleted' do
      link_1 = create :link
      link_2 = create :link
      page.links = [link_1, link_2]
      page.save!
      expect { page.destroy }.to change { Link.count }.by -2
    end
  end

  describe 'liquid_layout' do
    let(:switcher) { instance_double(PagePluginSwitcher, switch: nil) }
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
        page.title = 'just changin the title here'
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
      expect { image_2.destroy }.to change { Image.count }.by(-1)
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

  describe '#campaign_action_count' do
    context 'without campaign' do
      subject { create(:page, action_count: 5) }

      it 'returns action count for page' do
        expect(subject.campaign_action_count).to eq(5)
      end
    end

    context 'with campaign' do
      let(:campaign) { create(:campaign) }
      subject { create(:page, campaign: campaign) }

      it 'returns count for all campaign pages' do
        expect(campaign).to receive(:action_count)
        subject.campaign_action_count
      end
    end
  end

  describe '#dup' do
    let(:image) { create(:image, page: page) }

    before do
      page.update(primary_image: image)
    end

    subject { page.dup }

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

    context 'Given the title has non ascii characters' do
      let!(:page) { create(:page, title: 'öla', language: create(:language, :german)) }
      it 'transliterates the title according to the pages language' do
        expect(page.slug).to eq('oela')
      end
    end

    context 'duplicate slug' do
      it 'is invalid' do
        page_with_dup = build(:page, title: 'new title!', slug: 'simple-slug', liquid_layout: liquid_layout)
        expect { page_with_dup.save! }.to raise_error(
          ActiveRecord::RecordInvalid, /Slug has already been taken/
        )
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
      [create(:plugins_petition, page: page), create(:call_tool, page: page), create(:plugins_actions_thermometer, page: page)]
      plugin_names = %w[petition call_tool actions_thermometer]
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

  describe 'canonical_url' do
    context 'is valid when' do
      it 'nil' do
        page.canonical_url = nil
        expect(page).to be_valid
      end

      it 'empty string' do
        page.canonical_url = ''
        expect(page).to be_valid
      end

      it 'full url' do
        page.canonical_url = 'https://google.com'
        expect(page).to be_valid
      end
    end

    context 'is invalid when' do
      it 'url has no protocol' do
        page.canonical_url = 'google.com'
        expect(page).to be_invalid
      end

      it 'without full url' do
        page.canonical_url = 'https://lol'
        expect(page).to be_invalid
      end

      it 'with a newline' do
        page.canonical_url = "https://example.com\n"
        expect(page).to be_invalid
      end
    end
  end

  describe 'meta_tags' do
    it 'is invalid if it has the wrong format' do
      page.meta_tags = 'random text <hello>'
      expect(page).to be_invalid
      expect(page.errors[:meta_tags]).to be_present
    end

    it 'is invalid if it doesn\'t contain at least one META tag' do
      page.meta_tags = '<hello> </hello>'
      expect(page).to be_invalid
      expect(page.errors[:meta_tags]).to be_present
    end
  end

  describe 'total donations counter' do
    let!(:page_with_donations) { create :page, total_donations: 101_000 }

    it 'increments the total donations counter' do
      FactoryBot.create(:payment_braintree_transaction, page: page_with_donations, amount: 10, currency: 'USD')
      expect(page_with_donations.reload.total_donations.to_s).to eq '102000.0'
    end

    it 'updates the total donations counter when a GoCardless transaction is created' do
      expect(page.total_donations).to eq 0
      FactoryBot.create(:payment_go_cardless_transaction, page: page, amount: 10, currency: 'USD')
      expect(page.total_donations.to_s).to eq '1000.0'
    end

    it 'updates the total donations counter with a converted amount when a donation is created in another currency' do
      converted_amount = double(amount: 10, currency: 'EUR')
      total_donations = double(cents: page.total_donations)
      allow(Money).to receive(:new).and_return(total_donations)
      allow(Money).to receive(:from_amount).and_return(converted_amount)
      allow(converted_amount).to receive(:exchange_to).with('USD').and_return(double(cents: 1200))

      expect(page.total_donations).to eq 0
      FactoryBot.create(:payment_braintree_transaction, page: page, amount: 10, currency: 'EUR')
      expect(page.total_donations.to_s).to eq '1200.0'
    end
  end

  describe '#donation_page?' do
    let(:page) { create :page }

    context 'petition' do
      before do
        create(:plugins_petition, page: page)
        create(:plugins_fundraiser, page: page)
        create(:plugins_actions_thermometer, page: page)
        create(:plugins_donations_thermometer, page: page)
      end

      it 'should return false' do
        expect(page.donation_page?).to be false
      end
    end

    context 'donation' do
      before do
        create(:plugins_fundraiser, page: page)
        create(:plugins_donations_thermometer, page: page)
      end

      it 'should return true' do
        expect(page.donation_page?).to be true
      end
    end

    context 'calltool' do
      before do
        create(:call_tool, page: page)
      end

      it 'should return false' do
        expect(page.donation_page?).to be false
      end
    end
  end

  describe '#plugin_thermometers' do
    let(:page) { create :page }

    before do
      create(:plugins_petition, page: page)
      create(:plugins_fundraiser, page: page)
      create(:call_tool, page: page)
      create(:plugins_donations_thermometer, page: page)
      create(:plugins_actions_thermometer, page: page)
    end

    it 'should return donations and actions thermometer alone' do
      expect(page.plugin_thermometers.size).to eql 3
      expect(page.plugin_thermometers.map(&:type)).to include('DonationsThermometer', 'ActionsThermometer')
    end
  end

  describe '#plugin_thermometer_data' do
    let(:page) { create :page }

    context 'donation thermometer' do
      before do
        create(:plugins_fundraiser, page: page)
        create(:plugins_donations_thermometer, page: page)
      end

      it 'should return donations thermometer' do
        expect(page.plugin_thermometer_data.dig('type')).to include('DonationsThermometer')
      end
    end

    context 'action thermometer' do
      before do
        # Petition plugin are created first generally.
        # so the sequence is maintained here as it is
        create(:plugins_petition, page: page)
        create(:plugins_actions_thermometer, page: page)
        create(:plugins_fundraiser, page: page)
        create(:plugins_donations_thermometer, page: page)
      end

      it 'should return actions thermometer' do
        expect(page.plugin_thermometer_data.dig('type')).to include('ActionsThermometer')
      end
    end
  end
end
