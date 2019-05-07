class ArticlesController < ApplicationController
  def index
    @pages = Page.published.order('updated_at DESC')
  end
end
