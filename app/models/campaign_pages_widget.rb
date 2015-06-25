require_relative '../../lib/model_helpers/campaign_pages_widget_model_helper'

class CampaignPagesWidget < ActiveRecord::Base
  has_paper_trail

  belongs_to :campaign_page, inverse_of: :campaign_pages_widgets
  belongs_to :widget_type
  has_one :actionkit_page

  validates_presence_of :content, :page_display_order, :campaign_page_id, :widget_type_id
  # validates that the page display order integer is unique across the widgets with that campaign page id
  validates_uniqueness_of  :page_display_order, :scope => :campaign_page_id

  before_save :validate_image_name

  def validate_image_name
    # Will return false and prevent saving if the image name included in the content isn't valid.
    image_name_valid self.content
  end
end
