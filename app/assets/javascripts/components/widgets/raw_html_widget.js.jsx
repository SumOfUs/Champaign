var Widget = require('components/widgets/widget')
var RawHtmlWidgetForm = require('components/widgets/raw_html_widget_form')

var RawHtmlWidget = React.createClass({

  propTypes: {
    html:             React.PropTypes.string.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form() {
    return (
      <div className='widget-edit'>
        <RawHtmlWidgetForm {...this.props}>
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
        <Widget {...this.props} form={this.form} display={this.display}>
        </Widget>
      </div>
    )
  }
})

module.exports = RawHtmlWidget;
