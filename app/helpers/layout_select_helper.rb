# frozen_string_literal: true

module LayoutSelectHelper
  def construct_layout_select_class(liquid_layout, page, field)
    hidden = check_hidden(liquid_layout, field)
    active = check_active(liquid_layout, page, field)
    post_action_layout = liquid_layout.post_action_layout ? 'post-action-layout' : ''
    primary_layout = liquid_layout.primary_layout ? 'primary-layout' : ''
    "#{hidden} #{active} #{primary_layout} #{post_action_layout}"
  end

  def specify_layout_types(field)
    field == :liquid_layout_id ? 'primary' : 'follow-up'
  end

  private

  def check_hidden(liquid_layout, field)
    if field == :liquid_layout_id
      return 'hidden' unless liquid_layout.primary_layout
    elsif field == :follow_up_liquid_layout_id
      return 'hidden' unless liquid_layout.post_action_layout
    end
    ''
  end

  def check_active(liquid_layout, page, field)
    if field == :follow_up_liquid_layout_id && page.follow_up_plan.to_sym == :with_page
      return '' # the redirect option will be the active one in this case
    end

    # page.send(field) calls either page.liquid_layout_id or page.follow_up_liquid_layout_id
    liquid_layout.id == page.send(field) ? 'active' : ''
  end
end
