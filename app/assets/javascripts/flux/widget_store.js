var Fluxxor = require('fluxxor');

var events = {
  LOAD_WIDGETS:   "LOAD_WIDGETS",
  UPDATE_WIDGET:  "UPDATE_WIDGET",
  CREATE_WIDGET:  "CREATE_WIDGET",
  DESTROY_WIDGET: "DESTROY_WIDGET"
}

var WidgetStore = Fluxxor.createStore({

  initialize: function(){
    this.widgets = [];

    this.bindActions(
      events.LOAD_WIDGETS,   this.onLoadWidgets,
      events.UPDATE_WIDGET,  this.onUpdateWidget,
      events.CREATE_WIDGET,  this.onCreateWidget,
      events.DESTROY_WIDGET, this.onDestroyWidget
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

module.exports = {
  store: WidgetStore,
  events: events
}
