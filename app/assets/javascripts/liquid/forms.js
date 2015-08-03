$(function(){

  $('form.actions').on('submit', function(e){
    var $form = $(this);
    e.preventDefault();
    $.post( $form.attr('action'), $form.serialize() );
  });

  $('form.foo').on('submit', function(e){
    e.preventDefault();
    $(this).fadeOut(function(){

    });
  });
});
