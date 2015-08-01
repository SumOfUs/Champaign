var Fluxxor      = require('fluxxor');
var WidgetStore  = require('flux/widget_store');
var WidgetClient = require('flux/widget_client');

var actions = {
  loadWidgets: function(){
    WidgetClient.load( function(data){
      this.dispatch(WidgetStore.events.LOAD_WIDGETS, {widgets: data});
    }.bind(this))
  },

  updateWidget: function(data) {
    WidgetClient.update(data, function(resp) {
      this.dispatch(WidgetStore.events.UPDATE_WIDGET, data);
    }.bind(this));
  },

  createWidget: function(data) {
    WidgetClient.create(data, function(resp) {
      data.id = resp.id
      this.dispatch(WidgetStore.events.CREATE_WIDGET, data);
    }.bind(this));
  },

  destroyWidget: function(id){
    WidgetClient.destroy(id, function(resp) {
      this.dispatch(WidgetStore.events.DESTROY_WIDGET, id);
    }.bind(this));
  }
};

var stores = {
  WidgetStore: new WidgetStore.store()
};

var flux = new Fluxxor.Flux(stores, actions);

module.exports = flux;