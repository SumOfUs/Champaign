var flux   = require('flux/main');
var mixins = require('flux/mixins');
var Widgets = require('components/widgets/widgets');
let ContentForm = require('components/content');

var WidgetsEditor = React.createClass({
  mixins: [mixins.FluxMixin, mixins.StoreWatchMixin("WidgetStore")],

  getInitialState() {
    return { widgets: [] };
  },

  getDefaultProps() {
    return { flux: flux };
  },

  getStateFromFlux() {
    var store = this.getFlux().store("WidgetStore");

    return {
      data: store.widgets
    };
  },

  componentDidMount() {
    this.getFlux().actions.loadWidgets();
  },

  handleWidgetSubmit(data) {
    this.getFlux().actions.updateWidget(data);
  },

  render() {
    return (
      <div className='widgets'>
        <div className='content-form'>
          <ContentForm />
        </div>
      </div>
    )
  }
})

module.exports = WidgetsEditor;

//<Widgets widgets={this.state.data} campaign_page_id={ this.props.id } />
