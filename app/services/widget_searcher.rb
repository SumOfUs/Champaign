class WidgetSearcher

  #1. assign @queries to all search options in the params (these should be populated from the filter form)
  #2. get ALL campaign pages, pass them as the collection to the search function
    # This is very inefficient, but doing 'where field like' queries scans the entire table anyway so unless
    # we use a search engine, it'll be equally inefficient in any case if we call full_text_search?
  #3. go through all of the relevant search filters (the ones that were specified in the search parameters),
    # selecting from the collection the ones that correspond to the search parameters
  #4. return what's left

  def initialize(params)
    # could be initialized as a collection of queries (@queries) instead, for the next step
    @query = params[:search]
    @collection = CampaignPage.all
  end

  def full_text_search(collection, field, query)
    collection.where("#{field} LIKE ?", "%#{query}%")
    # TextBodyWidget.where("content ->> 'text_body_html' LIKE ?", "%la%")
    # "column_data ->> 'array' LIKE ?"

  end

  def content_search(collection, query)
    # get matches by title
    self.full_text_search(collection, 'title', query)

    # get matches by text body widget's contents
    matching_widgets = self.full_text_search(TextBodyWidget.all, "content ->> 'text_body_html'", query)

    # get the union of campaign pages matched by title and by text body
    collection << CampaignPage.find(matching_widgets.pluck(:page_id))
    collection.uniq

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

  # Could be updated to (recursively) go through all of the search conditions and return the collection that remains
  def search
    self.content_search(@collection, @query)
  end

end
