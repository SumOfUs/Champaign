var Widget = require('components/widgets/widget')
var TextBodyWidgetFields = require('components/widgets/text_body/fields')

var TextBodyWidgetForm = React.createClass({

  propTypes: {
    text_body_html:     React.PropTypes.string.isRequired,
    page_display_order: React.PropTypes.number.isRequired,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number.isRequired
  },

  fields(submitData) {
    return (
      <div className='widget-edit'>
        <TextBodyWidgetFields {...this.props} submitData={submitData} />
      </div>
    )
  },

  preview() {
    return (
      <div className='widget-show' dangerouslySetInnerHTML={{__html: this.props.text_body_html}}>
      </div>
    )
  },

  render() {
    return (
      <div className="text-body-widget">
        <Widget {...this.props} fields={this.fields} preview={this.preview} title="Text Body Widget" />
      </div>
    )
  }
});

module.exports = TextBodyWidgetForm;
