(function(){
  var initialize = function(){
    makeSortable();
    bindHandlers();
  };

  var makeSortable = function(){
    $( ".list-group.sortable" ).sortable();
  };

  var bindHandlers = function(){
    $('.collection-editor #new_collection_element').on('ajax:success', function(e, resp, c){
      $('.list-group').append(resp);
    });

    $('.collection-editor').on('ajax:success', "a[data-method=delete]", function(){
      $(this).parents('.list-group-item').fadeOut();
    });


    $( ".collection-editor" ).on( "sortupdate", function( event, ui, a, b ) {
      var ids = ui.item.parent().
        children().
          map(function(i, el){
            return $(el).data('id');
          }).get().join();

      $('#form_element_ids').val(ids);
      $('form#sort-collection-elements').submit();
    });

    $('#change-form-template').on('ajax:success', function(e, resp) {
      $('.form-edit').html(resp.html);
      makeSortable();

      // Updates the inline form's action URL with the new form ID.
      $('#sort-collection-elements, #new_collection_element').each(function(i, el){
        var action = $(el).attr('action').replace(/\d+/, resp.form_id);
        $(el).attr('action', action);
      });
    });
  };

  $.subscribe("collection:edit:loaded", initialize);
}());

