var WidgetFormErrors = require('components/widgets/widget_form_errors');
var ReactQuill = require('react-quill');
var mixins = require('flux/mixins');

var TextBodyWidgetForm = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string,
    submitData:       React.PropTypes.func.isRequired,
    errors:           React.PropTypes.object,
    id:               React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  getInitialState() {
    return {
      text_body_html: this.props.text_body_html
    }
  },

  serialize() {
    var text = this.state.text_body_html;
    var pdo = React.findDOMNode(this.refs.pdo).value;
    return {text_body_html: text, type: 'TextBodyWidget', page_display_order: pdo};
  },

  handleSubmit(e) {
    e.preventDefault();
    this.props.submitData(this.props, this.serialize());
  },

  textChanged(value) {
    this.setState({text_body_html: value});
  },

  render() {
    return (
      <div className='widget-html-form'>
         <form onSubmit={ this.handleSubmit }>
          <WidgetFormErrors errors={this.props.errors} />
          <div className="form-group">
            <label htmlFor="">Slot</label>
            <input type='number' className='form-control' ref='pdo' defaultValue={this.props.page_display_order}></input>
          </div>
          <div className="form-group">
            <ReactQuill theme="snow" defaultValue={this.props.text_body_html} onChange={this.textChanged} />
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})

module.exports = TextBodyWidgetForm