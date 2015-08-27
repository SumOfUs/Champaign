$(function(){
  var makeSortable = function(){
    $( ".plugin.action .list-group.sortable" ).sortable();

  };
  $('.plugin.action #new_form_element').on('ajax:success', function(e, resp, c){
    $('.list-group').append(resp);
  });

  $('.plugin.action #new_form_element').on('ajax:error', function(a,b,c){});

  $('.plugin.action').on('ajax:success', "a[data-method=delete]", function(){
    $(this).parents('.list-group-item').fadeOut();
  });


  $( ".plugin.action" ).on( "sortupdate", function( event, ui, a, b ) {
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

    var action = $('#sort-form-elements').
      attr('action').
      replace(/\d+/, resp.form_id);

    $('#sort-form-elements').attr('action', action);


    makeSortable();
  });

  makeSortable();
});

