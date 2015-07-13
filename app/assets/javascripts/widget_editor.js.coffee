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

  bind_events: ->
    @$new_button.on 'click', @new_widget

window.WidgetEditor = WidgetEditor