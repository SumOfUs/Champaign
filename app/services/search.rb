module Search

  # matches content with a WHERE x LIKE query
  def self.full_text_search(collection, field, query)
    collection.where("#{field} ILIKE ?", "%#{query}%")
  end

  class PageSearcher
    def self._search(string)
      CampaignPage.joins(:widgets).
        where("campaign_pages.title ILIKE ? OR widgets.content #>> '{text_body_html}' ILIKE ?", "%#{string}%", "%#{string}%")
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
        end
      end
      @collection
    end

    def search_by_title(query)
      @collection = Search.full_text_search(@collection, 'title', query)
    end

    def search_by_text(query)
      # find text body widgets that match the query, and get their page IDs
      matching_widgets = Search::WidgetSearcher.text_widget_search(query).pluck(:page_id)
      # union of campaign pages matched by title and by text body
      arr = (search_by_title(query) | CampaignPage.find(matching_widgets)).uniq
      # Problem: combining collections in nearly any way converts the outcome into an array
      #...which breaks all subsequent AR methods on @collection. Which is why I map it again into
      # an AR collection with yet another DB call. If you have a better idea on how to do this,
      # please share!
      @collection = CampaignPage.where(id: arr.map(&:id))
    end

    def search_by_tags(query)
      @collection = @collection.joins(:tags).where(tags: {id: query})
    end

  end

  class WidgetSearcher

    def initialize(params)
      @queries = params[:search]
      @collection = Widget.all
    end

    def self.text_widget_search(query)
      # get matches by text body widgets' contents
      Search.full_text_search(TextBodyWidget.all, "content ->> 'text_body_html'", query)
    end

  end

end
