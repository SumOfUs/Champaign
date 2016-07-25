class Page < ActiveRecord::Base
  extend FriendlyId
  has_paper_trail

  enum follow_up_plan: [:with_liquid, :with_page] # todo - :with_link
  enum publish_status: [:published, :unpublished, :archived]

  belongs_to :language
  belongs_to :campaign # Note that some pages do not necessarily belong to campaigns
  belongs_to :liquid_layout
  belongs_to :follow_up_page, class_name: 'Page'
  belongs_to :follow_up_liquid_layout, class_name: 'LiquidLayout'
  belongs_to :primary_image, class_name: 'Image'

  has_many :tags, through: :pages_tags
  has_many :actions
  has_many :pages_tags, dependent: :destroy
  has_many :images,     dependent: :destroy
  has_many :links,      dependent: :destroy

  scope :language,  -> (code) { code ? joins(:language).where(languages: { code: code }) : all }
  scope :published, -> { where(active: true) }
  scope :featured,  -> { where(featured: true) }

  validates :title, presence: true
  validates :liquid_layout, presence: true
  validates :publish_status, presence: true
  validate  :primary_image_is_owned

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
      action_count: 0
    )

    clone
  end

  def number_of_pages_with_matching_title
    Page.where(title: title).count
  end

  def slug_candidates
    [
      :title,
      [:title, :number_of_pages_with_matching_title]
    ]
  end

  private

  def switch_plugins
    fields = ["liquid_layout_id", "follow_up_liquid_layout_id", "follow_up_plan"]
    if fields.any?{ |f| changed.include?(f) }
      secondary = (follow_up_plan == 'with_liquid') ? follow_up_liquid_layout : nil
      PagePluginSwitcher.new(self).switch(liquid_layout, secondary)
    end
  end

  def primary_image_is_owned
    unless primary_image_id.blank? || images.map(&:id).include?(primary_image_id)
      errors.add(:primary_image_id, "is not one of the page's images")
    end
  end
end

