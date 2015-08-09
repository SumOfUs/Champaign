var Widget = require('components/widgets/widget')
var ThermometerWidgetFields = require('components/widgets/thermometer/fields')

var ThermometerWidgetForm = React.createClass({

  propTypes: {
    goal:               React.PropTypes.string,
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
        <Widget {...this.props} fields={this.fields} preview={this.preview} title="Thermometer Widget">
        </Widget>
      </div>
    )
  }
});

module.exports = ThermometerWidgetForm;