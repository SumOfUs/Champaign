var WidgetForm = require('components/widgets/widget_form')
var ThermometerWidgetFields = require('components/widgets/thermometer/fields')

var ThermometerWidgetForm = React.createClass({

  propTypes: {
    goal:               React.PropTypes.number,
    page_display_order: React.PropTypes.number,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number
  },

  fields(submitData) {
    return (
      <div className='widget-edit'>
        <ThermometerWidgetFields {...this.props} submitData={submitData} />
      </div>
    )
  },

  preview() {
    return (
      <div className='widget-show'>
        Goal: {this.props.goal} signatures
      </div>
    )
  },

  render() {
    return (
      <div className="thermometer-widget">
        <WidgetForm {...this.props} fields={this.fields} preview={this.preview} title="Thermometer Widget" />
      </div>
    )
  }
});

module.exports = ThermometerWidgetForm;
