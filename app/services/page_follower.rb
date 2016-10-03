# frozen_string_literal: true
class PageFollower
  include Rails.application.routes.url_helpers

  def self.new_from_page(page, member_id=nil)
    new(page.follow_up_plan, page.slug, page.follow_up_liquid_layout_id, page.follow_up_page.try(:slug), member_id)
  end

  def initialize(plan, page_slug, follow_up_liquid_layout_id, follow_up_page_slug, member_id=nil)
    @plan = plan
    @page_slug = page_slug
    @follow_up_page_slug = follow_up_page_slug
    @follow_up_liquid_layout_id = follow_up_liquid_layout_id
    @member_id = member_id
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
    return nil if @follow_up_page_slug.blank?
    return member_facing_page_path(@follow_up_page_slug) if @member_id.blank?
    member_facing_page_path(@follow_up_page_slug, member_id: @member_id)
  end

  def path_to_follow_up_layout
    return nil if @page_slug.blank? || @follow_up_liquid_layout_id.blank?
    return follow_up_member_facing_page_path(@page_slug) if @member_id.blank?
    follow_up_member_facing_page_path(@page_slug, member_id: @member_id)
  end
end
