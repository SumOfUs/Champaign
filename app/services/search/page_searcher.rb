class Search::PageSearcher

  def self._search(string)
    CampaignPage.joins(:widgets).
        where("campaign_pages.title ILIKE ? OR widgets.content #>> '{text_body_html}' ILIKE ?", "%#{string}%", "%#{string}%")
  end

  def get_pages_by_widgets(pages_collection, widgets_collection)
    # get campaign page ids from your collection of widgets
    pages_matching_widgets = widgets_collection.pluck(:page_id)
    # get a union of all of your pages and the pages that belong to the matching widgets
    # (this returns an array instead of an AR collection, so it needs to be mapped back)
    arr = (pages_collection | CampaignPage.find(pages_matching_widgets)).uniq
    # map from array back to AR collection
    @collection = CampaignPage.where(id: arr.map(&:id))
  end

  def initialize(params)
    @queries = params[:search]
    @collection = CampaignPage.all
  end

  def search
    [*@queries].each do |search_type, query|
      case search_type
        when 'content_search'
          search_by_text(query)
        when 'tags'
          search_by_tags(query)
        when 'language'
          search_by_language(query)
        when 'campaign'
          search_by_campaign(query)
      end
    end
    @collection
  end

  def search_by_title(query)
    @collection = Search.full_text_search(@collection, 'title', query)
  end

  def search_by_text(query)
    @collection = get_pages_by_widgets(@collection, Search::WidgetSearcher.text_widget_search(query))
  end

  def search_by_tags(query)
    @collection = @collection.joins(:tags).where(tags: {id: query})
  end

  def search_by_language(query)
    @collection = @collection.where(language_id: query)
  end

  def search_by_campaign(query)
    @collection = @collection.where(campaign_id: query)
  end

end
