var WidgetActions = require('components/widgets/widget_actions');
var mixins = require('flux/mixins');

var Widget = React.createClass({

  propTypes: {
    form:    React.PropTypes.func.isRequired,
    display: React.PropTypes.func.isRequired,
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

  form() {
    if(this.state.edit) { return this.props.form(this.submitData) }
  },

  display() {
    if(!this.state.edit) { return this.props.display() }
  },

  componentWillReceiveProps(nextProps){
    this.setState({edit: (typeof nextProps.errors === "object")})
  },

  render(){
    var [form, display] = [this.form(), this.display()]
    return (
      <div className='widget'>
        <WidgetActions {...this.props} toggleEditShow={this.toggleEditShow} parentWidget={this}>
        </WidgetActions>
        { form }
        { display }
      </div>
    )
  }
})

module.exports = Widget
