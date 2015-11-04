require 'render_anywhere'

class Page < ActiveRecord::Base
  include RenderAnywhere
  has_paper_trail

  belongs_to :language
  belongs_to :campaign # Note that some pages do not necessarily belong to campaigns
  belongs_to :liquid_layout
  belongs_to :secondary_liquid_layout, class_name: 'LiquidLayout'
  belongs_to :primary_image, class_name: 'Image'

  has_many :pages_tags, dependent: :destroy
  has_many :tags, through: :pages_tags
  has_many :actions
  has_many :images, dependent: :destroy
  has_many :links, dependent: :destroy

  validates :title, :slug, presence: true, uniqueness: true
  validates :liquid_layout, presence: true
  validate :primary_image_is_owned

  before_validation :create_slug
  after_save :switch_plugins

  # have we thought about using friendly id? probably better
  def create_slug
    self.slug = title.parameterize if slug.nil? and not title.nil?
  end

  # Compiles the HTML for this Page so that it can be used by external display apps.
  def compile_html
    PageRenderer.new(self).render_and_save
  end

  def liquid_data
    attributes.merge(link_list: links.map(&:attributes))
  end

  def plugins
    Plugins.registered.map do |plugin_class|
      plugin_class.where(page_id: id).to_a
    end.flatten
  end

  def shares
    [Share::Facebook, Share::Twitter, Share::Email].inject([]) do |variations, share_class|
      variations += share_class.where(page_id: id)
    end
  end

  def image_to_display
    primary_image || images.first
  end

  private

  def switch_plugins
    if changed.include?("liquid_layout_id")
      PagePluginSwitcher.new(self).switch(liquid_layout)
    end
  end

  def primary_image_is_owned
    unless primary_image_id.blank? || images.map(&:id).include?(primary_image_id)
      errors.add(:primary_image_id, "is not one of the page's images")
    end
  end
end

