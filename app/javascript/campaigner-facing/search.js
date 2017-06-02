(function(){

  var searchConfig = function() {

    $('.page-filter__reset').click( function() {
      $('select.selectize-container').map(function(index, item){
        item.selectize.clear();
      });
      $(this).closest('form').find('.form-control').map(function(index, item){
        $(item).val("");
      });
    });

    $('#pages-table').DataTable({
      /* Disable initial sort */
      "aaSorting": []
    });
  }

  $.subscribe("search:load", searchConfig);
}());
