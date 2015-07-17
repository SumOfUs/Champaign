class TemplateParameters < PageParameters

  def permit
    format_widget_attributes(params, :template)
    contents = save_json(params, :template)
    permitted = strip_json(params, :template).require(:template).permit(
      :id,
      :active,
      :template_name,
      widgets_attributes: [:id, :type, :page_display_order, :_destroy]
    )
    return restore_json(permitted, contents)
  end
end
