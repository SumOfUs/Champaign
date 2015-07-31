var flux   = require('flux/widgets');
var mixins = require('flux/mixins');
var Widgets = require('components/widgets/widgets');

var WidgetsEditor = React.createClass({
  mixins: [mixins.FluxMixin, mixins.StoreWatchMixin("WidgetsStore")],

  getInitialState() {
    
    // This is a hack cause Fluxxor and react-rails don't play nicely
    // The problem is that Fluxxor want us to pass the flux instance 
    // to the <WidgetsEditor> instance like this:
    //    React.render(<WidgetsEditor flux={flux} campaign_page_id={window.campaign_page_id} />, document.getElementById("widgets"));
    // but if we run our JS that way, we can't take advantage of the
    // react-rails server-side react rendering. instead, do this
    // so that flux gets passed down through context
    this.props.flux = flux;
    console.log("WE props",this.props);
    
    return { widgets: [] };
  },

  getStateFromFlux: function() {
    var store = flux.store("WidgetsStore");

    return {
      data: store.widgets
    };
  },

  componentDidMount: function() {
    flux.actions.loadWidgets();
  },

  handleWidgetSubmit(data) {
    flux.actions.updateWidget(data);
  },

  render() {
    return (
      <div className='widgets'>
        <Widgets widgets={this.state.data} campaign_page_id={ this.props.id } />
      </div>
    )
  }
})

module.exports = WidgetsEditor;

