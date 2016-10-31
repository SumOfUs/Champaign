# frozen_string_literal: true
class PageFollower
  include Rails.application.routes.url_helpers

  PARAMS_TO_PASS = [:member_id, :bucket].freeze

  def self.new_from_page(page, extra_params = nil)
    new(page.follow_up_plan, page.slug, page.follow_up_liquid_layout_id, page.follow_up_page.try(:slug), extra_params)
  end

  def self.follow_up_path(page, extra_params = nil)
    new_from_page(page, extra_params).follow_up_path
  end

  def initialize(plan, page_slug, follow_up_liquid_layout_id, follow_up_page_slug, extra_params = nil)
    @plan = plan
    @page_slug = page_slug
    @follow_up_page_slug = follow_up_page_slug
    @follow_up_liquid_layout_id = follow_up_liquid_layout_id
    @extra_params = extra_params.try(:symbolize_keys)
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
    member_facing_page_path(@follow_up_page_slug, **url_params)
  end

  def path_to_follow_up_layout
    return nil if @page_slug.blank? || @follow_up_liquid_layout_id.blank?
    follow_up_member_facing_page_path(@page_slug, **url_params)
  end

  def url_params
    return {} if @extra_params.blank?
    return @url_params if @url_params.present?
    @url_params = {}.tap do |ps|
      PARAMS_TO_PASS.each do |key|
        ps[key] = @extra_params[key] if @extra_params.key?(key)
      end
    end
  end
end
