html = '<%=j render partial: 'forms/add_element', locals: {form: @form, form_element: @form_element} %>'
$('.forms-add-element').html html
$.publish("forms:edit:loaded")
