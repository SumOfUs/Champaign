formEdit = '<%=j render partial: 'forms/edit', locals: {form: @form} %>'
formNew =  '<%=j render partial: 'forms/add_element', locals: {form: @form, form_element: FormElement.new} %>'

$('.forms-edit').html formEdit
$('.forms-add-element').html formNew
$('#form_element_label').focus()
$.publish("forms:edit:loaded")

