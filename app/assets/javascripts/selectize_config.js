$(function(){
  $('.selectize-container').selectize({
    plugins: ['remove_button'],
    closeAfterSelect: true
  });

  $('.radio-group input[type="radio"]').on('change', function(e){
    var $target = $(e.target);
    $target.parents('.radio-group').find('.radio-group__option').removeClass('active');
    $target.parents('.radio-group__option').addClass('active');
  });
});
