(function(){


  var initialize = function(){
    $('#plugins_action_form_id').on('change', function(){
      var item = $(this).find( "option:selected" );
      console.log('item selected', item);
    });
  }

  $(function(){
    initialize();
  });
}());


