var WidgetActions = require('components/widgets/widget_actions')

var Widget = React.createClass({

  propTypes: {
    form:    React.PropTypes.func.isRequired,
    display: React.PropTypes.func.isRequired,
    title:   React.PropTypes.string
  },

  getInitialState() {
    return { edit: false };
  },

  toggleEditShow() {
    this.setState( {edit: !this.state.edit} );
  },

  form() {
    if(this.state.edit) { return this.props.form() }
  },

  display() {
    if(!this.state.edit) { return this.props.display() }
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
