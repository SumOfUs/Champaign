class Search::WidgetSearcher

  def self.text_widget_search(query)
    # get matches by text body widgets' contents
    Search.full_text_search(TextBodyWidget.all, "content ->> 'text_body_html'", query)
  end

  def self.widget_type_search(query)
    Widget.where({type: query})
  end

end
