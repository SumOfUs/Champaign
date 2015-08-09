var mixins = require('flux/mixins');

var RawHtmlWidgetFields = React.createClass({

  propTypes: {
    html:             React.PropTypes.string,
    errors:           React.PropTypes.object,
    id:               React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  serialize() {
    var text = React.findDOMNode(this.refs.body).value;
    return {html: text, text: text, type: 'RawHtmlWidget' };
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
            <label htmlFor="">HTML</label>
            <textarea className='form-control' ref='body' defaultValue={this.props.html}></textarea>
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})

module.exports = RawHtmlWidgetFields;
