(function() {

  var initialize = function() {
    var handleSuccess = function(e, data, status, xhr){
      $(this).find('input').val('');
      $(this).find('input.form-control:first').focus();
      $('.elements-list').append("<li class='list-group-item'>" + data + "</li>");
    };

    var handleError = function(xhr, status, error) {
      console.log(error);
      $(this).find('input').val('').first().focus()
    };


    $('.form-element').on('ajax:success', handleSuccess);
    $('.form-element').on('ajax:error', handleError);
  };

  $.subscribe("form:has_loaded", initialize);
}());

