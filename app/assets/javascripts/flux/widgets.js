window.FluxMixin = Fluxxor.FluxMixin(React);
window.StoreWatchMixin = Fluxxor.StoreWatchMixin;

var constants = {
  LOAD_WIDGETS:   "LOAD_WIDGETS",
  UPDATE_WIDGET:  "UPDATE_WIDGET",
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

  destroy: function(id, success){
    $.ajax({
      url: "/campaign_pages/" + window.campaign_page_id + "/widgets/" + id,
      type: 'DELETE'
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

  destroyWidget: function(id){
    WidgetClient.destroy(id, function(resp) {
      this.dispatch(constants.DESTROY_WIDGET(id));
    }.bind(this));
  }
};

var WidgetsStore = Fluxxor.createStore({
  initialize: function(){
    this.widgets = [];

    this.bindActions(
      constants.LOAD_WIDGETS,   this.onLoadWidgets,
      constants.UPDATE_WIDGET,  this.onUpdateWidget,
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

  onDestroyWidget: function(id) {
    console.log('destroyed', id);
  }
});

var stores = {
  WidgetsStore: new WidgetsStore()
};

var flux = new Fluxxor.Flux(stores, actions);
