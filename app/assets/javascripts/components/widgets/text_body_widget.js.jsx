var Widget = require('components/widgets/widget')
var TextBodyWidgetForm = require('components/widgets/text_body_widget_form')

var TextBodyWidget = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form(submitData) {
    return (
      <div className='widget-edit'>
        <TextBodyWidgetForm {...this.props} submitData={submitData}>
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
        <Widget {...this.props} form={this.form} display={this.display} title="Text Body Widget">
        </Widget>
      </div>
    )
  }
});

module.exports = TextBodyWidget;