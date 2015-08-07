var Widget = require('components/widgets/widget')
var ThermometerWidgetForm = require('components/widgets/thermometer_widget_form')

var ThermometerWidget = React.createClass({

  propTypes: {
    goal:               React.PropTypes.string,
    page_display_order: React.PropTypes.number,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number
  },

  form(submitData) {
    return (
      <div className='widget-edit'>
        <ThermometerWidgetForm {...this.props} submitData={submitData}>
        </ThermometerWidgetForm>
      </div>
    )
  },

  display() {
    return (
      <div className='widget-show'>
        Goal: {this.props.goal} signatures
      </div>
    )
  },

  render() {
    return (
      <div className="thermometer-widget">
        <Widget {...this.props} form={this.form} display={this.display} title="Thermometer Widget">
        </Widget>
      </div>
    )
  }
});

module.exports = ThermometerWidget;