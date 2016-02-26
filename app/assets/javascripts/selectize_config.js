$(function(){
  $select = $('.selectize-container').selectize({
    plugins: ['remove_button'],
    closeAfterSelect: true
  });

 $('.page-filter__reset').click( function() {
   $select.map(function(index, item){
     item.selectize.clear();
   });
   $(this).closest('form').find('.form-control').map(function(index, item){
     $(item).val("");
   });
 });
});
