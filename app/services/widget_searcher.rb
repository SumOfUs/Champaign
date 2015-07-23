class WidgetSearcher

  #1. assign @queries to all search options in the params (these should be populated from the filter form)
  #2. get ALL campaign pages, pass them as the collection to the search function
    # This is very inefficient, but doing 'where field like' queries scans the entire table anyway so unless
    # we use a search engine, it'll be equally inefficient in any case if we call full_text_search?
  #3. go through all of the relevant search filters (the ones that were specified in the search parameters),
    # selecting from the collection the ones that correspond to the search parameters
  #4. return what's left

  def initialize(params)
    @queries = params[:search]
    @collection = CampaignPage.all
    # Managing each search type could be handled by individual classes / modules
  end

  # Could be updated to go through all of the search conditions and return the collection that remains
  def search
    # if queries haven't been specified (on initial page load), get all campaign pages
    if @queries.nil?
      return @collection
    # else, exclude campaign pages that do not match the search conditions from the collection
      # (right now only works with searching text content)
    else
      self.search_text_content(@collection, @queries[:content_search])
    end
  end

  def search_text_content(collection, query)
    # return the union of campaign pages matched by title and by text body
    (get_matches_by_title(collection, query) | get_matches_by_text_widget(query)).uniq
  end

  def get_matches_by_title(collection, query)
    self.full_text_search(collection, 'title', query)
  end

  def get_matches_by_text_widget(query)
    # get matches by text body widget's contents
    matching_widgets = self.full_text_search(TextBodyWidget.all, "content ->> 'text_body_html'", query)
    CampaignPage.find(matching_widgets.pluck(:page_id))
  end

  # matches content with a WHERE x LIKE query
  def full_text_search(collection, field, query)
    # TODO - make this case insensitive
    collection.where("#{field} LIKE ?", "%#{query}%")
  end

  def tag_search(options)
    # Set the initial return of an empty set
    campaign_pages = []

    # If we have a tag_name parameter, then search by it.

    # TODO: Needs to integrate with other search options or we need to make a decision that
    # search options are distinct from one another.
    if options.has_key? :tag_name
      campaign_pages = CampaignPage.joins(:tags).where(tags: {tag_name: options[:tag_name]})
    end
    campaign_pages
  end

end
