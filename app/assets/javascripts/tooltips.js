(function(){
  $.subscribe("pages:new pages:edit form:edit", function(){
    $('[data-toggle="tooltip"]').tooltip()
  });
}());
