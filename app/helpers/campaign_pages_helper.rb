module CampaignPagesHelper
  def campaign_page_nav_item(text, path)
    klass = current_page?(path) ? 'active' : nil

    content_tag :li, class: klass do
      link_to text, path
    end
  end

  def toggle_switch(state, active, label)
    klass = (active == state ? 'btn-success' : '')
    klass += " btn toggle-button btn-default"

    content_tag :a, label, class: klass
  end
end
