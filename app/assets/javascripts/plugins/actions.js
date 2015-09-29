$(function(){
  $('form.action').on('ajax:error', window.Champaign.showErrors);

  $('form.action').on('ajax:success', function(e, data){
    if (data.follow_up_url) {
      window.location.href = data.follow_up_url
    } else {
      // this should never happen, but just in case.
      alert("You've signed the petition! Thanks so much!");
    }
  });
});


