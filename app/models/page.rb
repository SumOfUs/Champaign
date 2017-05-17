# frozen_string_literal: true
# == Schema Information
#
# Table name: pages
#
#  id                         :integer          not null, primary key
#  language_id                :integer
#  campaign_id                :integer
#  title                      :string           not null
#  slug                       :string           not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  compiled_html              :text
#  status                     :string           default("pending")
#  messages                   :text
#  content                    :text             default("")
#  featured                   :boolean          default(FALSE)
#  liquid_layout_id           :integer
#  follow_up_liquid_layout_id :integer
#  action_count               :integer          default(0)
#  primary_image_id           :integer
#  ak_petition_resource_uri   :string
#  ak_donation_resource_uri   :string
#  follow_up_plan             :integer          default(0), not null
#  follow_up_page_id          :integer
#  javascript                 :text
#  publish_status             :integer          default(1), not null
#  optimizely_status          :integer          default(0), not null
#  canonical_url              :string
#  allow_duplicate_actions    :boolean          default(FALSE)
#  enforce_styles             :boolean          default(FALSE), not null
#  notes                      :text
#  publish_actions            :integer          default(0), not null
#

class Page < ApplicationRecord
  extend FriendlyId
  has_paper_trail

  enum follow_up_plan: [:with_liquid, :with_page] # TODO: - :with_link
  enum publish_status: [:published, :unpublished, :archived]
  enum optimizely_status: [:optimizely_enabled, :optimizely_disabled]
  enum publish_actions: [:secure, :default_hidden, :default_published]

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

  scope :language,  ->(code) { code ? joins(:language).where(languages: { code: code }) : all }
  scope :featured,  -> { where(featured: true) }

  validates :title, presence: true
  validates :liquid_layout, presence: true
  validates :publish_status, presence: true
  validate  :primary_image_is_owned
  validates :canonical_url, allow_blank: true, format: { with: %r{\Ahttps{0,1}:\/\/.+\..+\z} }

  after_save :switch_plugins

  friendly_id :slug_candidates, use: [:finders, :slugged]

  def liquid_data
    attributes.merge(link_list: links.map(&:attributes))
  end

  def plugins
    Plugins.registered.map do |plugin_class|
      plugin_class.where(page_id: id).to_a
    end.flatten.sort_by(&:created_at)
  end

  def plugin_names
    plugins.map { |plugin| plugin.model_name.name.split('::')[1].downcase }
  end

  def tag_names
    tags.map { |tag| tag.name.downcase }
  end

  def shares
    [Share::Facebook, Share::Twitter, Share::Email].inject([]) do |variations, share_class|
      variations += share_class.where(page_id: id)
    end
  end

  def image_to_display
    primary_image || images.first
  end

  def meta_tags
    tag_names << plugin_names
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
      [:transliterated_title, :number_of_pages_with_matching_title]
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

  private

  def switch_plugins
    fields = %w(liquid_layout_id follow_up_liquid_layout_id follow_up_plan)
    if fields.any? { |f| changed.include?(f) }
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
end
