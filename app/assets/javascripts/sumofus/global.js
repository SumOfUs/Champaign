$(document).ready(function(){
  $('.select2').each(function(ii, select){
    $(select).select2({
      placeholder: $(select).attr('placeholder'),
      width: "resolve"
    });
  })
});
