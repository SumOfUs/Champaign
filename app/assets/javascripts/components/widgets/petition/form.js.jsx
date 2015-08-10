var WidgetForm = require('components/widgets/widget_form')
var PetitionWidgetFields = require('components/widgets/petition/fields')

var PetitionWidgetForm = React.createClass({

  propTypes: {
    petition_text:      React.PropTypes.string,
    form_button_text:   React.PropTypes.string,
    require_full_name:  React.PropTypes.boolean,
    page_display_order: React.PropTypes.number,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number
  },

  fields(submitData) {
    return (
      <div className='widget-edit'>
        <PetitionWidgetFields {...this.props} submitData={submitData} />
      </div>
    )
  },

  preview() {
    return (
      <div className='widget-show'>
        <div className='content-block' dangerouslySetInnerHTML={{__html: this.props.petition_text}}></div>
        <div className='content-block'>
          Button text: {this.props.form_button_text}
        </div>
        <div className='content-block'>
          Collect name: {this.props.require_full_name} signatures
        </div>
      </div>
    )
  },

  render() {
    return (
      <div className="petition-widget">
        <WidgetForm {...this.props} fields={this.fields} preview={this.preview} title="Petition Widget" />
      </div>
    )
  }
});

module.exports = PetitionWidgetForm;
