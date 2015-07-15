class WidgetEditor
  constructor: ({@library, @new_button, @editor, @type_selector, @fieldsets, @delete_button, @widget_fields, @destroy_field, @undelete_button, @deleted_info}) ->
    @bind_jquery()
    @bind_events()

  bind_jquery: ->
    @$editor        = $(@editor)
    @$library       = @$editor.find(@library)
    @$fieldsets     = @$editor.find(@fieldsets)
    @$new_button    = @$editor.find(@new_button)
    @$type_selector = @$editor.find(@type_selector)

  new_widget: =>
    widget_type = @$type_selector.val()
    cloned = @$library.find(".#{widget_type}").clone()
    @$fieldsets.append( @update_child_index(cloned) )
    @bind_events() # some of the new elements need event bindings

  delete_widget: (evt) =>
    field_container = $(evt.target).parents(@widget_fields)
    field_container.find(@destroy_field).val(true)
    field_container.find('fieldset').addClass('hidden-deleted')
    field_container.find(@deleted_info).removeClass('hidden-irrelevant')

  undelete_widget: (evt) =>
    evt.preventDefault()
    field_container = $(evt.target).parents(@widget_fields)
    field_container.find(@destroy_field).val(false)
    field_container.find('fieldset').removeClass('hidden-deleted')
    field_container.find(@deleted_info).addClass('hidden-irrelevant')

  update_child_index: (template) ->
    unique_index = new Date().getTime()
    template.html(template.html().replace(/replace_with_unique_idx/g, unique_index))

  remove_library: (evt) =>
    # don't submit the data in the template widget forms
    evt.preventDefault()
    @$library.remove()
    evt.target.submit()

  bind_events: ->
    @$new_button.on 'click', @new_widget
    @$editor.parents('form').on 'submit', @remove_library
    @$editor.find(@delete_button).on 'click', @delete_widget
    @$editor.find(@undelete_button).on 'click', @undelete_widget

window.WidgetEditor = WidgetEditor
