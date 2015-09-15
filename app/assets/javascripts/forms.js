(function(){
  var initialize = function(){
    makeSortable();
    bindHandlers();
  };

  var makeSortable = function(){
    $( ".list-group.sortable" ).sortable();
  };

  var bindHandlers = function(){
    $('.form-editor #new_form_element').on('ajax:success', function(e, resp, c){
      $('.list-group').append(resp);
    });

    $('.form-editor #new_form_element').on('ajax:error', function(a,b,c){});

    $('.form-editor').on('ajax:success', "a[data-method=delete]", function(){
      $(this).parents('.list-group-item').fadeOut();
    });


    $( ".form-editor" ).on( "sortupdate", function( event, ui, a, b ) {
      var ids = ui.item.parent().
        children().
          map(function(i, el){
            return $(el).data('id');
          }).get().join();

      $('#form_element_ids').val(ids);
      $('form#sort-form-elements').submit();
    });

    $('#change-form-template').on('ajax:success', function(e, resp) {
      $('.form-edit').html(resp.html);
      makeSortable();

      // Updates the inline form's action URL with the new form ID.
      $('#sort-form-elements, #new_form_element').each(function(i, el){
        var action = $(el).attr('action').replace(/\d+/, resp.form_id);
        $(el).attr('action', action);
      });
    });
  };

  $.subscribe("forms:edit:loaded", initialize);
}());

