var WidgetActions = require('components/widgets/widget_actions');
var mixins = require('flux/mixins');

var WidgetForm = React.createClass({

  propTypes: {
    fields:    React.PropTypes.func.isRequired,
    preview: React.PropTypes.func.isRequired,
    errors:  React.PropTypes.object,
    title:   React.PropTypes.string
  },

  mixins: [mixins.FluxMixin],

  getInitialState() {
    return { edit: false };
  },

  toggleEditShow() {
    this.setState( {edit: !this.state.edit} );
  },

  addMetadata(data) {
    var store = this.getFlux().store("WidgetStore");
    data.page_id = store.page_id;
    data.page_type = store.page_type;
  },

  submitData(formProps, data) {
    this.addMetadata(data);
    if ('id' in formProps) {
      data.id = formProps.id;
      this.getFlux().actions.updateWidget(data);
    } else {
      this.getFlux().actions.createWidget(data);
    }
    this.toggleEditShow();
  },

  fields() {
    if(this.state.edit) { return this.props.fields(this.submitData) }
  },

  preview() {
    if(!this.state.edit) { return this.props.preview() }
  },

  componentWillReceiveProps(nextProps){
    this.setState({edit: (typeof nextProps.errors === "object")})
  },

  render(){
    var [fields, preview] = [this.fields(), this.preview()]
    return (
      <div className='widget'>
        <WidgetActions {...this.props} toggleEditShow={this.toggleEditShow} parentWidget={this} />
        { fields }
        { preview }
      </div>
    )
  }
})

module.exports = WidgetForm;
