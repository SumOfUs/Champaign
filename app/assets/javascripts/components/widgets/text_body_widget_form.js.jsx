var ReactQuill = require('react-quill');
var mixins = require('flux/mixins');

var TextBodyWidgetForm = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string,
    submitData:       React.PropTypes.func.isRequired,
    id:               React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  getDefaultState() {
    return {
      text_body_html: this.props.text_body_html
    }
  },

  serialize() {
    var text = this.state.text_body_html;
    return {text_body_html: text, type: 'TextBodyWidget'};
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