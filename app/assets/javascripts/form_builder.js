$(function(){
  $('.form-element').on('ajax:before', function(){
    console.log('before');
  });

  $('.form-element').on('ajax:error', function(a, st){
    console.log('error');
  });

  $(".form-element").on("ajax:success", function(e,data, status, xhr){
    $('.elements-list').append("<li class='list-group-item'>" + data + "</li>");
  });
});

