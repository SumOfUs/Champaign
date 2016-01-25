class PageFollower
  include Rails.application.routes.url_helpers

  def initialize(plan, page_id, follow_up_liquid_layout_id, follow_up_page_id)
    @plan = plan
    @page_id = page_id
    @follow_up_page_id = follow_up_page_id
    @follow_up_liquid_layout_id = follow_up_liquid_layout_id
  end

  def follow_up_path
    case @plan
    when :with_page
      path_to_follow_up_page || path_to_follow_up_layout
    when :with_liquid
      path_to_follow_up_layout || path_to_follow_up_page
    else
      raise ArgumentError, "follow up plan '#{@plan}' is not a valid plan"
    end
  end

  private

  def path_to_follow_up_page
    page_path(@follow_up_page_id) unless @follow_up_page_id.blank?
  end

  def path_to_follow_up_layout
    follow_up_page_path(@page_id) unless @page_id.blank? || @follow_up_liquid_layout_id.blank?
  end
end

