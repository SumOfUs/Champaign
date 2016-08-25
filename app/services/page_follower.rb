# frozen_string_literal: true
class PageFollower
  include Rails.application.routes.url_helpers

  def self.new_from_page(page)
    new(page.follow_up_plan, page.slug, page.follow_up_liquid_layout_id, page.follow_up_page.try(:slug))
  end

  def initialize(plan, page_slug, follow_up_liquid_layout_id, follow_up_page_slug)
    @plan = plan
    @page_slug = page_slug
    @follow_up_page_slug = follow_up_page_slug
    @follow_up_liquid_layout_id = follow_up_liquid_layout_id
  end

  def follow_up_path
    case @plan.try(:to_sym)
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
    member_facing_page_path(@follow_up_page_slug) unless @follow_up_page_slug.blank?
  end

  def path_to_follow_up_layout
    follow_up_member_facing_page_path(@page_slug) unless @page_slug.blank? || @follow_up_liquid_layout_id.blank?
  end
end
