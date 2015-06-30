# The parameters classes specify which parameters are allowed for mass assignment and permits those
class CampaignPageParameters < ActionParameter::Base

  def permit
    params.require(:campaign_page).permit(
      :title, 
      :slug, 
      :active, 
      :featured, 
      :template_id, 
      :campaign_id, 
      :language_id,
      {:tags => []},
      campaign_pages_widgets_attributes: [:id, :widget_type_id, :content, :page_display_order]
    )
  end

  def convert_tags(tags)
    # Tags come in to the campaign pages controller as strings, we convert them into
    # integers so they can be used in a `Tag.find` call without problems

    final_tags = []
    tags.each do |tag|
      if tag == ''
        # Sometimes, the form sends an empty string along with Tag IDs.
        # This breaks `Tag.find` for obvious reasons, so we skip it
        # here to make sure that we don't have that problem
        next
      end
      final_tags.push tag.to_i
    end
    final_tags
  end
end
