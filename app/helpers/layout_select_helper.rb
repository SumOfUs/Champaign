module LayoutSelectHelper

  def specify_layout_types(field)
    (field == :liquid_layout_id) ? 'primary' : 'follow-up'
  end

  def construct_layout_select_class(ll, offer_redirect, f, field)
    liquid_matters = (!offer_redirect || f.object.follow_up_plan.to_sym == :with_liquid)
    # TODO: if layout_types is 'follow-up' and field (follow_up_liquid_layout_id) is nil, use default_follow_up_layout
    # if that is nil, fall back to redirect
    # TODO: if layout_types is 'primary' and field (liquid_layout_id) is not nil, set active to element whose id matches field
    active_class = (ll.id == f.object.send(field) && liquid_matters) ? 'active' : ''

    primary_layout, post_action_layout = assign_layout_class(ll, field)
    # primary_layout = ll.primary_layout ? hide_irrelevant[:primary_class] : ''
    # post_action_layout = ll.post_action_layout ? hide_irrelevant[:post_action_class] : ''
    return "btn btn-default radio-group__option #{active_class} #{primary_layout} #{post_action_layout}"
  end

  def hide_irrelevant(field)
    # Append the class "hidden" to primary layouts if the form is for follow-up layouts,
    # and to follow-up layouts if it's for primary layouts
    primary_layout_class = 'primary-layout'
    post_action_layout_class = 'post-action-layout'
    (specify_layout_types(field) == 'primary' ? post_action_layout_class : primary_layout_class) << ' hidden'
    return {
        primary_class: primary_layout_class,
        post_action_class: post_action_layout_class
    }
  end

  def assign_layout_class(ll, field)
    # Assigns the 'primary-layout' or 'post-action-layout' classes to the liquid layout belongs to either category,
    # and uses hide_irrelevant to append 'hidden' class to the one that is irrelevant.
    primary_layout = ll.primary_layout ? hide_irrelevant(field)[:primary_class] : ''
    post_action_layout = ll.post_action_layout ? hide_irrelevant(field)[:post_action_class] : ''
    return primary_layout, post_action_layout
  end

  def assign_active_class

  end
end