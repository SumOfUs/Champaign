var WidgetClient = {
  load: function(data, success) {
    $.getJSON("/"+ data.page_type + "s/" + data.page_id + "/widgets.json", function(data){
      success(data);
    })
  },

  update: function(data, success, failure){
    $.ajax({
      type: "PUT",
      url: "/"+ data.page_type + "s/" + data.page_id + "/widgets/" + data.id,
      data: {widget: data },
      success: success,
      error: failure
    })
  },

  create: function(data, success, failure){
    $.ajax({
      type: "POST",
      url: "/"+ data.page_type + "s/" + data.page_id + "/widgets/",
      data: {widget: data },
      success: success,
      error: failure
    });
  },

  destroy: function(data, success, failure){
    $.ajax({
      type: 'DELETE',
      url: "/"+ data.page_type + "s/" + data.page_id + "/widgets/" + data.id,
      success: success,
      error: failure
    });
  }
};

module.exports = WidgetClient;
