class Search::PageSearcher

  def self._search(string)
    CampaignPage.joins(:widgets).
        where("campaign_pages.title ILIKE ? OR widgets.content #>> '{text_body_html}' ILIKE ?", "%#{string}%", "%#{string}%")
  end

  def get_pages_by_widgets(collection, widgets_collection)
    # get campaign page ids from your collection of widgets
    page_ids = widgets_collection.pluck(:page_id)
    # get an intersection of page ids and original ids in the collection
    array_to_relation(CampaignPage, collection.find(page_ids))
  end

  def combine_collections(collection1, collection2)
    # get union of unique values in collection1 and collection2
    arr = (collection1 | collection2).uniq
    # map from array back to AR collection
    array_to_relation(CampaignPage, arr)
  end

  def array_to_relation(model, arr)
    model.where(id: arr.map(&:id))
  end

  def initialize(params)
    @queries = params[:search]
    @collection = CampaignPage.all
  end

  def search
    pp 'in search, queries are ', @queries.inspect, @queries.class
    @queries.each do |search_type, query|
      case search_type
        when 'content_search'
          search_by_text(query)
        when 'tags'
          search_by_tags(query)
        when 'language'
          search_by_language(query)
        when 'campaign'
          search_by_campaign(query)
        when 'widget_type'
          search_by_widget_type(query)
        else
          pp 'did not match any case in switch'
      end
    end
    @collection
  end

  def search_by_title(query)
    @collection = Search.full_text_search(@collection, 'title', query)
  end

  def search_by_text(query)
    text_body_matches = get_pages_by_widgets(@collection, Search::WidgetSearcher.text_widget_search(query))
    pp 'text body matches', text_body_matches.inspect, text_body_matches.class
    @collection = combine_collections(search_by_title(query), text_body_matches)
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

  def search_by_widget_type(query)
    # gets all widgets that match the query
    widget_type_matches = Search::WidgetSearcher.widget_type_search(query)
    # gets pages in the collection that match the page_ids in the widgets
    @collection = get_pages_by_widgets(@collection, widget_type_matches)
  end

end
