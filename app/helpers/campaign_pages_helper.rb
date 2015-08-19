module CampaignPagesHelper
  def campaign_page_nav_item(text, path)
    klass = current_page?(path) ? 'active' : nil

    content_tag :li, class: klass do
      link_to text, path
    end
  end
end
