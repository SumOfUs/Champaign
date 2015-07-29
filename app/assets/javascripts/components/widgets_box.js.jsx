var FluxMixin = Fluxxor.FluxMixin(React),
    StoreWatchMixin = Fluxxor.StoreWatchMixin;

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

  onUpdateWidget: function(id) {
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


var WidgetsBox = React.createClass({
  mixins: [FluxMixin, StoreWatchMixin("WidgetsStore")],

  getInitialState() {
    return { widgets: [] };
  },

 getStateFromFlux: function() {
    var store = this.getFlux().store("WidgetsStore");

    return {
      data: store.widgets
    };
  },

  componentDidMount: function() {
    this.getFlux().actions.loadWidgets();
  },

  handleWidgetSubmit(data) {
    this.getFlux().actions.updateWidget(data);
  },

  render() {
    return (
      <div className='widgets'>
        <Widgets onWidgetSubmit={this.handleWidgetSubmit} widgets={this.state.data} campaign_page_id={ this.props.campaign_page_id } />
      </div>
    )
  }
})

var Widgets = React.createClass({

  propTypes: {
    widgets:          React.PropTypes.array.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired
  },

  render(){
    var widgets = this.props.widgets.map(widget => {
      switch (widget.type) {
        case "TextBodyWidget":
          return (<TextBodyWidget {...widget} onWidgetSubmit={this.props.onWidgetSubmit}></TextBodyWidget>)
        case "RawHtmlWidget":
          return (<RawHtmlWidget {...widget} onWidgetSubmit={this.props.onWidgetSubmit}></RawHtmlWidget>)
        default:
          break;
      }
    })

    return (
      <div className="widgets">
        { widgets }
      </div>
    )
  }
});

$(function(){
  React.render(<WidgetsBox flux={flux} campaign_page_id={window.campaign_page_id} />, document.getElementById("widgets"));
});

