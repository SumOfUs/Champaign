var FluxMixin = Fluxxor.FluxMixin(React),
    StoreWatchMixin = Fluxxor.StoreWatchMixin;

var constants = {
  LOAD_WIDGETS: "LOAD_WIDGETS"
};

var WidgetsClient = {
  load: function(success) {
    $.getJSON("/campaign_pages/" + window.campaign_page_id + "/widgets.json", function(data){
      success(data);
    })
  }
};

var actions = {
  loadWidgets: function(){

    WidgetsClient.load( function(data){
      this.dispatch(constants.LOAD_WIDGETS, {widgets: data});
    }.bind(this))
  }
};

var WidgetsStore = Fluxxor.createStore({
  initialize: function(){
    this.widgets = [];

    this.bindActions(
      constants.LOAD_WIDGETS, this.onLoadWidgets
    );
  },

  onLoadWidgets: function(data) {
    this.data = data.widgets;
    console.log(data, 'just fetched');
    this.emit("change");
  }
});

var stores = {
  WidgetsStore: new WidgetsStore()
};

var flux = new Fluxxor.Flux(stores, actions);


var WidgetsBox = React.createClass({
  mixins: [FluxMixin, StoreWatchMixin("WidgetsStore")],

  getInitialState() {
    return { data: [] };
  },

 getStateFromFlux: function() {
    var store = this.getFlux().store("WidgetsStore");

    return {
      data: store.data
    };
  },

  componentDidMount: function() {
    this.getFlux().actions.loadWidgets();
  },

  handleWidgetSubmit(data) {
    $.ajax({
      type: "PUT",
      url: "/campaign_pages/" + this.props.campaign_page_id + "/widgets/" + data.widget.id,
      data: data
    }).done(function( data ) {
      this.setState({data: data})
    }.bind(this));
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
    console.log('widgets load', this.props.widgets);
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

