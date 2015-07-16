require 'render_anywhere'

class CampaignPageRenderer
  include RenderAnywhere

  def initialize(page)
    @page = page
  end

  def render_and_save
    @page.update_attributes(compiled_html: html)
  end

  private

  def html
    render partial: 'campaign_pages/page_compile', layout: false, locals: {campaign_page: @page}
  end
end
