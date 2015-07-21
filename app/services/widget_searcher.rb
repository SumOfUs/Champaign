class WidgetSearcher

  def initialize(params)
    # could be initialized as a collection of queries instead, for the next step
    @query = params[:search]
  end

  # Could be updated to (recursively) go through all of the search conditions and return the collection that remains
  def text_search(field, query)
    if not query.nil?
      @campaign_pages = CampaignPage.where("#{field} LIKE ?", "%#{query}%")
    else
      @campaign_pages = CampaignPage.all
    end
  end

  def search
    return self.text_search('title', @query)
  end

end

#1. search for search options in the params (field is contained in params?)
#2. filter campaign_pages by the relevant search
#3. go through all of the search filters
#4. return what's left