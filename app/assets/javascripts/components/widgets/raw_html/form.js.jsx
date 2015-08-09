var WidgetForm = require('components/widgets/widget_form')
var RawHtmlWidgetFields = require('components/widgets/raw_html/fields')

var RawHtmlWidgetForm = React.createClass({

  propTypes: {
    html:             React.PropTypes.string.isRequired,
    errors:           React.PropTypes.object,
    id:               React.PropTypes.number.isRequired
  },

  fields(submitData) {
    return (
      <div className='widget-edit'>
        <RawHtmlWidgetFields {...this.props} submitData={submitData} />
      </div>
    )
  },

  preview() {
    return (
      <div className='widget-show'>
        {this.props.html}
      </div>
    )
  },

  render() {
    return (
      <div className="text-body-widget">
        <WidgetForm {...this.props} fields={this.fields} preview={this.preview} title="Raw HTML Widget" />
      </div>
    )
  }
})

module.exports = RawHtmlWidgetForm;
