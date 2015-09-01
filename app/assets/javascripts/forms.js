(function() {

  var initialize = function() {
    var handleSuccess = function(e, data, status, xhr){
      $(this).find('input').val('');
      $(this).find('input.form-control:first').focus();
      $('.form-preview').append(data);
    };

    var handleDelete = function(e, data, status, xhr){
      $(this).parents('.form-element').fadeOut();
    };

    var handleError = function(xhr, status, error) {
      $(this).find('input').val('').first().focus()
    };

    $('.form-element').on('ajax:success', handleSuccess);
    $('.form-element').on('ajax:error',   handleError);

    $('body').on('ajax:success', "a[data-method=delete]", handleDelete);
  };

  $.subscribe("form:has_loaded", initialize);
}());

