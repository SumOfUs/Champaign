# require_relative 'widget_searcher'
# require_relative 'page_searcher'

module Search

  # matches content with a WHERE x LIKE query
  def self.full_text_search(collection, field, query)
    collection.where("#{field} ILIKE ?", "%#{query}%")
  end

end
