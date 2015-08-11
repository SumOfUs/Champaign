var WidgetFormErrors = require('components/widgets/widget_form_errors');
var SlotSelector     = require('components/widgets/slot_selector');
var ReactQuill = require('react-quill');
var mixins     = require('flux/mixins');

var PetitionWidgetFields = React.createClass({

  propTypes: {
    petition_text:      React.PropTypes.string,
    form_button_text:   React.PropTypes.string,
    require_full_name:  React.PropTypes.bool,
    require_email_address: React.PropTypes.bool,
    require_postal_code:  React.PropTypes.bool,
    page_display_order: React.PropTypes.number,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  getInitialState() {
    return { petition_text: this.props.petition_text }
  },

  serialize() {
    var serialized = {type: 'PetitionWidget'};
    serialized.petition_text         = this.state.petition_text;
    serialized.form_button_text      = React.findDOMNode(this.refs.form_button_text).value;
    serialized.require_full_name     = React.findDOMNode(this.refs.require_full_name).checked;
    serialized.require_email_address = React.findDOMNode(this.refs.require_email_address).checked;
    serialized.require_postal_code   = React.findDOMNode(this.refs.require_postal_code).checked;
    serialized.page_display_order    = this.refs.slotSelector.serialize().page_display_order;
    return serialized;
  },

  handleSubmit(e) {
    e.preventDefault();
    this.props.submitData(this.props, this.serialize());
  },

  textChanged(value) {
    this.setState({petition_text: value});
  },

  boolean(field, label) {
    return (
      <div className="form-group">
        <div className="checkbox">
          <label>
            <input type='checkbox'
                ref={field}
                id={field}
                defaultChecked={this.props[field]}>
            </input>
            {label}
          </label>
        </div>
      </div>
    )
  },

  render() {
    return (
      <div className='widget-html-form'>
         <form onSubmit={ this.handleSubmit }>
          <WidgetFormErrors errors={this.props.errors} />
          <SlotSelector ref="slotSelector" page_display_order={this.props.page_display_order} />
          <div className="form-group">
            <ReactQuill theme="snow" defaultValue={this.props.petition_text} onChange={this.textChanged} />
          </div>
          <div className="form-group">
            <label>Form button text</label>
            <input type='text' className='form-control' ref='form_button_text' defaultValue={this.props.form_button_text}></input>
          </div>
          { this.boolean('require_email_address', "Request signer's email") }
          { this.boolean('require_full_name', "Request signer's name") }
          { this.boolean('require_postal_code', "Request postal code") }
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})

module.exports = PetitionWidgetFields;
