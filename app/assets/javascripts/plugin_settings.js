$(function(){
  var handleCheckBox = function(e){
    $(this).parents('form').submit();
  };

  $('form.plugin-setting').
    on('change', "input[type='checkbox']", handleCheckBox);
});
