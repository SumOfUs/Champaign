import ErrorDisplay from '../shared/show_errors';

$(function() {
  var handleStart = function(e, i) {
    var button = $(e.target).find('.xhr-feedback');

    $(e.target).find('.xhr-feedback-saving').remove();

    button.prop('disabled', true);

    var feedback = $('<span />')
      .addClass('label label-success xhr-feedback-saving')
      .text('Saving...');

    button.after(feedback);
  };

  var enableButton = function(e) {
    var button = $(e.target).find('.xhr-feedback');
    button.prop('disabled', false);
  };

  var handleError = function(e, data) {
    enableButton(e);
    var feedback = $('.xhr-feedback-saving')
      .removeClass('label-success')
      .addClass('label-danger')
      .text('Save failed.');
    ErrorDisplay.show(e, data);
  };

  var handleSuccess = function(e) {
    enableButton(e);
    var feedback = $('.xhr-feedback-saving').text('Saved!');

    window.setTimeout(function() {
      feedback.fadeOut();
    }, 1000);
  };

  $('body').on('ajax:beforeSend', handleStart);
  $('body').on('ajax:success', handleSuccess);
  $('body').on('ajax:error', handleError);
});
