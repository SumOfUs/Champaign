# frozen_string_literal: true
class Search::PageSearcher
  def self.search(params)
    new(params).search
  end

  def initialize(params)
    @queries = params.blank? ? {} : params
    @collection = Page.all
  end

  def search
    @queries.each_pair do |search_type, query|
      next unless query.present?
      case search_type.to_sym
      when :content_search
        search_by_text(query)
      when :tags
        search_by_tags(query)
      when :language
        search_by_language(query)
      when :layout
        search_by_layout(query)
      when :campaign
        search_by_campaign(query)
      when :plugin_type
        search_by_plugin_type(query)
      when :publish_status
        search_by_publish_status(query)
      when :limit
        limit(query)
      when :order_by
        order_by(query)
      end
    end
    @collection | []
  end

  private

  def combine_collections(collection1, collection2)
    # get union of unique values in collection1 and collection2
    arr = (collection1 | collection2).uniq
    # map from array back to AR collection
    array_to_relation(Page, arr)
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
      if page.tags.any? && (tags.map(&:to_i) - page.tags.pluck('id')).empty?
        matches_by_tags.push(page)
      end
    end
    @collection = array_to_relation(Page, matches_by_tags)
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

  def limit(query)
    @collection = @collection.limit(query)
  end

  def search_by_plugin_type(query)
    matches_by_plugins = []
    filtered_pages = @collection.pluck(:id)
    query.each do |plugin_type|
      begin
        plugin_class = plugin_type.constantize
      # Rescue for invalid plugin name - constantize throws name error if a constant with the name hasn't been initialized.
      rescue
        next
      end
      plugin_class.page.each do |page_plugin|
        # If the page hasn't determined to be filtered from the collection yet
        next unless filtered_pages.include?(page_plugin.page_id)
        # If the plugin is active, add its page to matches
        if page_plugin.active?
          matches_by_plugins.push(page_plugin.page_id)
        else
          # If an inactive plugin is discovered, the page cannot be a match. Remove from filtered pages and matching pages.
          filtered_pages.delete(page_plugin.page_id)
          matches_by_plugins.delete(page_plugin.page_id)
        end
      end
    end
    # get pages that match ids of pages that contain the plugin type from the collection
    @collection = @collection.where(id: matches_by_plugins)
  end

  def search_by_publish_status(query)
    @collection = @collection.where(publish_status: query)
  end

  def order_by(query)
    return unless validate_order_by(query)
    query = "#{query[0]} #{query[1]}" if query.is_a? Array
    @collection = @collection.order(query)
  end

  def validate_order_by(query)
    acceptable = [:created_at, :updated_at, :title, :featured, :active]
    if query.is_a? Array
      acceptable.include? query[0].to_sym
    else
      acceptable.include? query.to_sym
    end
  end
end
