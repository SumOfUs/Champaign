# The parameters classes specify which parameters are allowed for mass assignment and permits those
class CampaignPageParameters < ActionParameter::Base

  def permit
    contents = save_json(params)
    permitted = strip_json(params).require(:campaign_page).permit(
      :id,
      :title,
      :slug,
      :active,
      :featured,
      :template_id,
      :campaign_id,
      :language_id,
      {:tags => []},
      widgets_attributes: [:id, :type, :page_display_order]
    )
    return restore_json(permitted, contents)
  end

  private

  # In order to pass strong params inspection with nested hashes with
  # unknown keys, we strip that part out and replace it after inspection

  def strip_json params
    return params unless params[:campaign_page][:widgets_attributes].present?
    params[:campaign_page][:widgets_attributes].each{ |a| a.delete(:content) }
    return params
  end

  def save_json params
    return nil unless params[:campaign_page][:widgets_attributes].present?
    return params[:campaign_page][:widgets_attributes].map do |a|
      a.has_key? :content ? a[:content] : nil
    end
  end

  def restore_json permitted, saved
    return permitted unless saved.present?
    permitted[:widgets_attributes].each_with_index do |a, ii|
      a[:content] = saved[ii] if saved[ii].present?
    end
    return permitted
  end

end
