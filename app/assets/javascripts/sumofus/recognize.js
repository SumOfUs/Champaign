$(document).ready(function(){
  $('#form-action-clear').on('click', function(){
    var irrelevants = $('.hidden-irrelevant');
    irrelevants.removeAttr('value');
    irrelevants.removeClass('hidden-irrelevant');
    $('.welcome-text').addClass('hidden-irrelevant');
  });
});