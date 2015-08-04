var WidgetClient = {
  load: function(data, success) {
    $.getJSON("/"+ data.page_type + "s/" + data.page_id + "/widgets.json", function(data){
      success(data);
    })
  },

  update: function(data, success){
    $.ajax({
      type: "PUT",
      url: "/"+ data.page_type + "s/" + data.page_id + "/widgets/" + data.id,
      data: {widget: data }
    }).done(success);
  },

  create: function(data, success){
    $.ajax({
      type: "POST",
      url: "/"+ data.page_type + "s/" + data.page_id + "/widgets/",
      data: {widget: data }
    }).done(success);
  },

  destroy: function(data, success){
    $.ajax({
      type: 'DELETE',
      url: "/"+ data.page_type + "s/" + data.page_id + "/widgets/" + data.id
    }).done(success);
  }
};

module.exports = WidgetClient;
