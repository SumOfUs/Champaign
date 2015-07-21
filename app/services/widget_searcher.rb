class WidgetSearcher

  def search(options)
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
