class WidgetEditor
  constructor: ({@library, @new_button, @editor, @type_selector, @fieldsets}) ->
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
    @$fieldsets.append(cloned)

  remove_library: (evt) =>
    # don't submit the data in the template widget forms
    evt.preventDefault()
    @$library.remove()
    evt.target.submit()

  bind_events: ->
    @$new_button.on 'click', @new_widget
    @$editor.parents('form').on 'submit', @remove_library

window.WidgetEditor = WidgetEditor