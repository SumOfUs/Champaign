var Widget = require('components/widgets/widget')
var RawHtmlWidgetForm = require('components/widgets/raw_html_widget_form')

var RawHtmlWidget = React.createClass({

  propTypes: {
    html:             React.PropTypes.string.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form(submitData) {
    return (
      <div className='widget-edit'>
        <RawHtmlWidgetForm {...this.props} submitData={submitData}>
        </RawHtmlWidgetForm>
      </div>
    )
  },

  display() {
    return (
      <div className='widget-show'>
        {this.props.html}
      </div>
    )
  },

  render() {
    return (
      <div className="text-body-widget">
        <Widget {...this.props} form={this.form} display={this.display} title="Raw HTML Widget">
        </Widget>
      </div>
    )
  }
})

module.exports = RawHtmlWidget;
