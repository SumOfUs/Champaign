var WidgetClient = {
  load: function(success) {
    $.getJSON("/campaign_pages/" + window.campaign_page_id + "/widgets.json", function(data){
      success(data);
    })
  },

  update: function(data, success){
    $.ajax({
      type: "PUT",
      url: "/campaign_pages/" + window.campaign_page_id + "/widgets/" + data.id,
      data: {widget: data }
    }).done(success);
  },

  create: function(data, success){
    $.ajax({
      type: "POST",
      url: "/campaign_pages/" + window.campaign_page_id + "/widgets/",
      data: {widget: data }
    }).done(success);
  },

  destroy: function(id, success){
    $.ajax({
      type: 'DELETE',
      url: "/campaign_pages/" + window.campaign_page_id + "/widgets/" + id
    }).done(success);
  }
};

module.exports = WidgetClient;
