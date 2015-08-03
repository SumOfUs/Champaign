# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#

$ ->
  $('.form-element').on 'ajax:success', ->
    $(this).find('input').val('')
    $(this).find('input.form-control:first').focus()

  $('.form-element').on 'ajax:error', ->
    console.log 'error'
    $(this).find('input').val('').first().focus()
