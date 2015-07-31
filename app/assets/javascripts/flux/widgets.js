var constants = {
  LOAD_WIDGETS:   "LOAD_WIDGETS",
  UPDATE_WIDGET:  "UPDATE_WIDGET",
  CREATE_WIDGET:  "CREATE_WIDGET",
  DESTROY_WIDGET: "DESTROY_WIDGET"
};

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

var actions = {
  loadWidgets: function(){

    WidgetClient.load( function(data){
      this.dispatch(constants.LOAD_WIDGETS, {widgets: data});
    }.bind(this))
  },

  updateWidget: function(data) {
    WidgetClient.update(data, function(resp) {
      this.dispatch(constants.UPDATE_WIDGET, data);
    }.bind(this));
  },

  createWidget: function(data) {
    WidgetClient.create(data, function(resp) {
      data.id = resp.id
      this.dispatch(constants.CREATE_WIDGET, data);
    }.bind(this));
  },

  destroyWidget: function(id){
    WidgetClient.destroy(id, function(resp) {
      this.dispatch(constants.DESTROY_WIDGET, id);
    }.bind(this));
  }
};

var WidgetsStore = Fluxxor.createStore({
  initialize: function(){
    this.widgets = [];

    this.bindActions(
      constants.LOAD_WIDGETS,   this.onLoadWidgets,
      constants.UPDATE_WIDGET,  this.onUpdateWidget,
      constants.CREATE_WIDGET,  this.onCreateWidget,
      constants.DESTROY_WIDGET, this.onDestroyWidget
    );
  },

  onLoadWidgets: function(data) {
    this.widgets = data.widgets;
    this.emit("change");
  },

  onUpdateWidget: function(data) {
    var pos = this.widgets.map(function(e) { return e.id; }).indexOf(data.id);
    window.widgets = this.widgets;
    this.widgets[pos] = data;
    this.emit("change");
  },

  onCreateWidget: function(data) {
    window.widgets = this.widgets; // just copying this from above
    this.widgets.push(data)
    this.emit("change");
  },

  onDestroyWidget: function(id) {
    console.log('destroyed', id);
  }
});

var stores = {
  WidgetsStore: new WidgetsStore()
};

var flux = new Fluxxor.Flux(stores, actions);

module.exports = flux;