var flux   = require('flux/main');
var mixins = require('flux/mixins');
var Widgets = require('components/widgets/widgets');

var WidgetsEditor = React.createClass({

  propTypes: {
    page_type:   React.PropTypes.string.isRequired,
    page_id:     React.PropTypes.number.isRequired
  },

  mixins: [mixins.FluxMixin, mixins.StoreWatchMixin("WidgetStore")],

  getInitialState() {
    return { widgets: [] };
  },

  getDefaultProps() {
    return { flux: flux };
  },

  pageMetadata() {
    return { page_id: this.props.page_id, page_type: this.props.page_type }
  },

  getStateFromFlux() {
    var store = this.getFlux().store("WidgetStore");

    return {
      data: store.widgets
    };
  },

  componentDidMount() {
    var metadata = this.pageMetadata();
    this.getFlux().actions.setPageMetadata(metadata);
    this.getFlux().actions.loadWidgets(metadata);
  },

  handleWidgetSubmit(data) {
    this.getFlux().actions.updateWidget(data);
  },

  render() {
    return (
      <div className='widgets'>
        <Widgets widgets={this.state.data} />
      </div>
    )
  }
})

module.exports = WidgetsEditor;

