$(function(){
  var $bar = $('.progress-bar'),
      page_id = $bar.data('page-id');


  var updateBar = function(data){
    var count  = data.actions_count,
        offset = parseInt($bar.attr('aria-valuenow'), 10),
        total  = parseInt($bar.attr('aria-valuemax'), 10),
        width  = (offset + count) / total * 100;

    $bar.css('width', width + "%");
  };

  var getCount = function(){
    var endpoint = "/api/pages/" + page_id + ".json";
    $.get(endpoint, function(data){
      updateBar(data);
    });
  };

  if($bar.length > 0) {
    getCount();
  };
});


$(function(){
  $('.gallery').on('click', 'img');
});

