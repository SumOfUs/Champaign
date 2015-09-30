(function(){
  var configureToggle = function() {
    var $stateInput = $('.plugin-active-field');

    var handleClick = function(e){
      e.preventDefault();
      $('form.plugin-toggle').submit();
      $('.toggle-button').removeClass('btn-primary');
      $(this).addClass('btn-primary');
    };

    var handleSuccess = function(e,data){};

    var handleError = function(xhr, status, error){
      console.log('error', status, error);
    };

    var updateState = function(){
      var state = !JSON.parse($stateInput.val());
      $stateInput.val(state);
    };

    $('.toggle-button').on('click', handleClick);

    $('form.plugin-toggle').on('ajax:before', updateState);
    $('form.plugin-toggle').on('ajax:success', handleSuccess);
    $('form.plugin-toggle').on('ajax:error', handleError);
  };

  $.subscribe("plugins:toggle", configureToggle);
}());

