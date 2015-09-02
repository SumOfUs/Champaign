$(function(){
  var handleStart = function(e,i){
    var button = $(e.target).find('.xhr-feedback');

    $(e.target).find(".xhr-feedback-saving").remove();

    button.prop('disabled', true);

    var feedback = $("<span />").
      addClass('label label-success xhr-feedback-saving').
      text('Saving...')

     button.after(feedback);
  };

  var handleError = function(a,b,c) {
    console.log(a,b,c);
  };

  var handleSuccess = function(e){
    var button = $(e.target).find('.xhr-feedback');
    button.prop('disabled', false);


    var feedback = $(".xhr-feedback-saving").
      text('Saved!')

    window.setTimeout( function(){
      feedback.fadeOut();
    }, 1000)
  };

  $('body').on('ajax:beforeSend', handleStart);
  $('body').on('ajax:success',    handleSuccess);
  $('body').on('ajax:error',      handleError);
});
