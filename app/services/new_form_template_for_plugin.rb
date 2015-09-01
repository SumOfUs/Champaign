class NewFormTemplateForPlugin
  def self.create(form, plugin)
    new_form = FormDuplicator.duplicate(form)
    plugin.update form: new_form
    new_form
  end
end
