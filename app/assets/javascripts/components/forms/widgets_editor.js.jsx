var flux   = require('flux/widgets');
var mixins = require('flux/mixins');
var Widgets = require('components/widgets/widgets');

var WidgetsEditor = React.createClass({
  mixins: [mixins.FluxMixin, mixins.StoreWatchMixin("WidgetsStore")],

  getInitialState() {
    return { widgets: [] };
  },

  getDefaultProps() {
    return { flux: flux };
  },

  getStateFromFlux() {
    var store = flux.store("WidgetsStore");

    return {
      data: store.widgets
    };
  },

  componentDidMount() {
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

