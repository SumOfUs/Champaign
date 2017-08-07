module CallToolHelper
  # Order matters for this multi-select. Selectize works by building a new
  # select element, then adding and deleting option tags to it as you add
  # and remove elements. But on page load, it populates the pre-selected
  # in their order from the original select, created here. Therefore, we
  # order the choices in the order they're stored in.
  def call_tool_target_by_attributes_options(plugin)
    plugin
      .target_filterable_fields
      .sort_by { |t| plugin.target_by_attributes.index(t.to_s) || Float::INFINITY }
      .map { |t| [t.to_s.titleize, t] }
  end
end
