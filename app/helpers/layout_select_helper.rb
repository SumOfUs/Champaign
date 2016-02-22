module LayoutSelectHelper

  def specify_layout_types(field)
    (field == :liquid_layout_id) ? 'primary' : 'follow-up'
  end

  def construct_layout_select_class(ll, offer_redirect, f, field)
    # Calls the other methods to create the expected set of classes for the layout select options
    primary_layout, post_action_layout = assign_layout_class(ll, field)
    return "btn btn-default radio-group__option #{assign_active_class(ll, f, field, offer_redirect)} #{primary_layout} #{post_action_layout}"
  end

  def liquid_matters(offer_redirect, f)
    (!offer_redirect || f.object.follow_up_plan.to_sym == :with_liquid)
  end

  def hide_irrelevant_layouts(field)
    # Sets the class name for each layout type.
    # Appends the class "hidden" to primary layouts if the form is for follow-up layouts,
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
    # and uses hide_irrelevant_layouts to append 'hidden' class to the one that is irrelevant.
    # It is possible for standalone pages to qualify as both a primary and a post action layout.
    primary_layout = ll.primary_layout ? hide_irrelevant_layouts(field)[:primary_class] : ''
    post_action_layout = ll.post_action_layout ? hide_irrelevant_layouts(field)[:post_action_class] : ''
    return primary_layout, post_action_layout
  end

  def assign_active_class(ll, f, field, offer_redirect)
    # Assigns the active visual effect to the correct field in the select form
    (ll.id == f.object.send(field) && liquid_matters(offer_redirect, f)) ? 'active' : ''
  end

end