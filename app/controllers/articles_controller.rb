class ArticlesController < ApplicationController
  def index
    @pages = Page.published.order('created_at DESC')
  end
end
