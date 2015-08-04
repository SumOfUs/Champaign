var mixins = require('flux/mixins');

var TextBodyWidgetForm = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string,
    submitData:       React.PropTypes.func.isRequired,
    id:               React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  serialize() {
    var text = React.findDOMNode(this.refs.body).value;
    return {text_body_html: text, type: 'TextBodyWidget'};
  },

  handleSubmit(e) {
    e.preventDefault();
    this.props.submitData(this.props, this.serialize());
  },

  render() {
    return (
      <div className='widget-html-form'>
         <form onSubmit={ this.handleSubmit }>
          <div className="form-group">
            <label htmlFor="">Text</label>
            <textarea className='form-control' ref='body' defaultValue={this.props.text_body_html}></textarea>
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})

module.exports = TextBodyWidgetForm