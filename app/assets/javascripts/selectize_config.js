$(function(){
  $('.selectize-container').selectize({
    plugins: ['remove_button'],
    closeAfterSelect: true
  });

  $('.radio-group input[type="radio"]').on('change', function(e){
    var $target = $(e.target);
    var name = $target.parents('.radio-group__option').find('.layout-settings__title').text();
    $target.parents('.layout-settings').find('.layout-settings__current').text(name);
    $target.parents('.radio-group').find('.radio-group__option').removeClass('active');
    $target.parents('.radio-group__option').addClass('active');
  });
});
