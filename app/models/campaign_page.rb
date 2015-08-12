require 'render_anywhere'

class CampaignPage < ActiveRecord::Base
  include RenderAnywhere
  has_paper_trail

  belongs_to :language
  belongs_to :campaign # Note that some campaign pages do not necessarily belong to campaigns

  has_many :campaign_pages_tags, dependent: :destroy
  has_many :tags, through: :campaign_pages_tags
  has_many :actions
  has_many :images

  validates :title, :slug, presence: true, uniqueness: true

  before_validation :create_slug

  # have we thought about using friendly id? probably better
  def create_slug
    self.slug = title.parameterize if slug.nil? and not title.nil?
  end

  # Compiles the HTML for this CampaignPage so that it can be used by external display apps.
  def compile_html
    CampaignPageRenderer.new(self).render_and_save
  end

  #
  # TODO - Refactor
  # Move to service class
  #
  def self.create_with_plugins(params)
    page = new(params)
    page.language = Language.first

    if page.save
      Plugins.registered.each do |plugin|
        Plugins.create_for_page(plugin, page)
      end

      ChampaignQueue::SqsPusher.push(@campaign_page.as_json) if Rails.env.production?
    end

    page
  end
end


