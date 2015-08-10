var Widget = require('components/widgets/widget')
var TextBodyWidgetForm = require('components/widgets/text_body_widget_form')

var TextBodyWidget = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form() {
    return (
      <div className='widget-edit'>
        <TextBodyWidgetForm {...this.props}>
        </TextBodyWidgetForm>
      </div>
    )
  },

  display() {
    return (
      <div className='widget-show'>
        {this.props.text_body_html}
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
});

module.exports = TextBodyWidget;