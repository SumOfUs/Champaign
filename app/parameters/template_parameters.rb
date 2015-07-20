class TemplateParameters < PageParameters

  def permit
    super(template_fields, :template)
  end

  def template_fields
    [ :id,
      :active,
      :template_name]
  end
end
