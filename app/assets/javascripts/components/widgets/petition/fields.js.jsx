var WidgetFormErrors = require('components/widgets/widget_form_errors');
var SlotSelector     = require('components/widgets/slot_selector');
var ReactQuill = require('react-quill');
var mixins     = require('flux/mixins');

var PetitionWidgetFields = React.createClass({

  propTypes: {
    petition_text:      React.PropTypes.string,
    form_button_text:   React.PropTypes.string,
    require_full_name:  React.PropTypes.boolean,
    page_display_order: React.PropTypes.number,
    errors:             React.PropTypes.object,
    id:                 React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  getInitialState() {
    return { petition_text: this.props.petition_text }
  },

  serialize() {
    var text = this.state.petition_text;
    var form_button_text = React.findDOMNode(this.refs.form_button_text).value;
    var require_full_name = React.findDOMNode(this.refs.require_full_name).value;
    var pdo = this.refs.slotSelector.serialize().page_display_order;
    return {page_display_order: pdo, petition_text: text, type: 'PetitionWidget',
            form_button_text: form_button_text, require_full_name: require_full_name };
  },

  handleSubmit(e) {
    e.preventDefault();
    this.props.submitData(this.props, this.serialize());
  },

  textChanged(value) {
    this.setState({petition_text: value});
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
          <div className="form-group">
            <div className="checkbox">
              <label>
                <input  type='checkbox'
                    ref='require_full_name'
                    id='require_full_name'
                    defaultChecked={this.props.require_full_name}>
                </input>
                Request signer's name
              </label>
            </div>
            <label htmlFor="require_full_name"></label>
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})

module.exports = PetitionWidgetFields;
