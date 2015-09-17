class Search::PageSearcher

  def initialize(params)
    @queries = params[:search]
    @collection = CampaignPage.all
  end

  def search
    [*@queries].each do |search_type, query|
      if not validate_query(query)
        next
      else
        case search_type.to_s
          when 'content_search'
            search_by_text(query)
          when 'tags'
            search_by_tags(query)
          when 'language'
            search_by_language(query)
          when 'layout'
            search_by_layout(query)
          when 'campaign'
            search_by_campaign(query)
          when 'plugin'
            search_by_plugin_type(query)
        end
      end
    end
    @collection | []
  end

  private

  def validate_query(query)
    # if query is an empty array, nil or an empty string, skip filtering for that query
    ( [[], nil, ''].include? query ) ? false : true
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

  def search_by_title(query)
    @collection = Search.full_text_search(@collection, 'title', query)
  end

  def search_by_text(query)
    matches_by_content = Search.full_text_search(@collection, 'content', query)
    @collection = combine_collections(search_by_title(query), matches_by_content)
  end

  def search_by_tags(tags)
    matches_by_tags = []
    @collection.each do |page|
      # if the page has tags and if the queried tags are a subset of the page's tags
      if page.tags.any? and (tags.map(&:to_i) - page.tags.pluck('id')).empty?
        matches_by_tags.push(page)
      end
    end
    @collection = array_to_relation(CampaignPage, matches_by_tags)
  end

  def search_by_language(query)
    @collection = @collection.where(language_id: query)
  end

  def search_by_campaign(query)
    @collection = @collection.where(campaign_id: query)
  end

  def search_by_layout(query)
    @collection = @collection.where(liquid_layout: query)
  end

  def search_by_plugin_type(plugins)
    matches_by_plugins = []
    plugins.each do |plugin_type|
      begin
        plugin_type.constantize.page.each do |plugin|
          # push into the array all records of pages that contain that plugin type
          if plugin.active?
            matches_by_plugins.push(plugin.campaign_page_id)
          end
        end
      rescue
        next
      end
    end
    # get pages that match ids of pages that contain the plugin type from the collection
    @collection = @collection.where(id: matches_by_plugins)
  end
end
