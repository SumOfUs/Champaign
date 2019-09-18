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

class Page < ApplicationRecord # rubocop:disable ClassLength
  extend FriendlyId
  has_paper_trail

  enum follow_up_plan: %i[with_liquid with_page] # TODO: - :with_link
  enum publish_status: %i[published unpublished archived]
  enum optimizely_status: %i[optimizely_enabled optimizely_disabled]
  enum publish_actions: %i[secure default_hidden default_published]

  belongs_to :language
  belongs_to :campaign # Note that some pages do not necessarily belong to campaigns
  belongs_to :liquid_layout
  belongs_to :follow_up_page, class_name: 'Page'
  belongs_to :follow_up_liquid_layout, class_name: 'LiquidLayout'
  belongs_to :primary_image, class_name: 'Image'

  has_many :pages_tags, dependent: :destroy
  has_many :tags, through: :pages_tags

  has_many :actions
  has_many :images,     dependent: :destroy
  has_many :links,      dependent: :destroy
  has_many :share_buttons, class_name: 'Share::Button'

  has_many :go_cardless_transactions, class_name: 'Payment::GoCardless::Transaction'
  has_many :go_cardless_subscriptions, class_name: 'Payment::GoCardless::Subscription'
  has_many :braintree_subscriptions, class_name: 'Payment::Braintree::Subscription'

  scope :language,  ->(code) { code ? joins(:language).where(languages: { code: code }) : all }
  scope :featured,  -> { where(featured: true) }

  validates :title, presence: true
  validates :liquid_layout, presence: true
  validates :publish_status, presence: true
  validates :slug, uniqueness: true, on: :create
  validate  :primary_image_is_owned
  validates :canonical_url, allow_blank: true, format: { with: %r{\Ahttps{0,1}:\/\/.+\..+\z} }
  validates :meta_description, length: { maximum: 140 }
  validate  :meta_tags_are_valid, if: ->(o) { o.meta_tags.present? }

  after_save :switch_plugins

  friendly_id :slug_candidates, use: %i[finders slugged]

  def liquid_data
    attributes.merge(link_list: links.map(&:attributes))
  end

  def plugins
    Plugins.registered.map do |plugin_class|
      plugin_class.where(page_id: id).to_a
    end.flatten.sort_by(&:created_at)
  end

  def plugin_names
    plugins.map { |plugin| plugin.name.demodulize.underscore }
  end

  def tag_names
    tags.map { |tag| tag.name.downcase }
  end

  def shares(type = nil)
    share_classes = case type
                    when 'local'
                      [Share::Whatsapp]
                    when 'sp'
                      [Share::Facebook, Share::Twitter, Share::Email]
                    else
                      [Share::Facebook, Share::Twitter, Share::Email, Share::Whatsapp]
                    end
    share_classes.inject([]) do |variations, share_class|
      variations += share_class.where(page_id: id)
    end
  end

  def image_to_display
    primary_image || images.first
  end

  def dup
    clone = super

    clone.assign_attributes(
      primary_image: nil,
      slug: nil,
      action_count: 0,
      featured: false
    )

    clone
  end

  def number_of_pages_with_matching_title
    Page.where(title: title).count
  end

  def slug_candidates
    [
      :transliterated_title,
      %i[transliterated_title number_of_pages_with_matching_title]
    ]
  end

  def campaign_action_count
    @campaign_action_count ||= if campaign
                                 campaign.action_count
                               else
                                 action_count
                               end
  end

  def language_code
    language&.code || I18n.default_locale
  end

  def optimization_tags
    tag_names << plugin_names
  end

  def subscriptions_count
    braintree_subscriptions.count + go_cardless_subscriptions.count
  end

  def donation_followup?
    follow_up_liquid_layout.try(:title).to_s.include?('donate')
  end

  private

  def switch_plugins
    fields = %w[liquid_layout_id follow_up_liquid_layout_id follow_up_plan]
    if fields.any? { |f| saved_changes.key?(f) }
      secondary = follow_up_plan == 'with_liquid' ? follow_up_liquid_layout : nil
      PagePluginSwitcher.new(self).switch(liquid_layout, secondary)
    end
  end

  def primary_image_is_owned
    unless primary_image_id.blank? || images.map(&:id).include?(primary_image_id)
      errors.add(:primary_image_id, "is not one of the page's images")
    end
  end

  def transliterated_title
    I18n.transliterate(title, locale: language_code || I18n.default_locale)
  end

  def meta_tags_are_valid
    xml = "<root> #{meta_tags} </root>"
    doc = Nokogiri::XML(xml)
    if doc.errors.any?
      errors.add(:meta_tags, 'seem to be invalid HTML code')
    elsif doc.xpath('/root//meta').empty? && doc.xpath('/root//META').empty?
      errors.add(:meta_tags, 'must contain a list of valid "META" or "meta" tags')
    end
  end
end
