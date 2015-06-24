class TagsController < ActionController::Base
  def search
    search_term = params[:search]
    possible_tags = Tag.where('tag_name ILIKE :query', query: "%#{search_term}%").limit(5)
    render json: possible_tags
  end
end
