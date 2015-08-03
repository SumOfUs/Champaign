var mixins = require('flux/mixins');

var RawHtmlWidgetForm = React.createClass({

  propTypes: {
    html:             React.PropTypes.string,
    id:               React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  handleSubmit(e) {
    e.preventDefault();
    var store = this.getFlux().store("WidgetStore");
    var text = React.findDOMNode(this.refs.body).value;
    var data = {html: text, text: text, type: 'RawHtmlWidget', page_id: store.page_id, page_type: store.page_type };
    if ('id' in this.props) {
      data.id = this.props.id;
      this.getFlux().actions.updateWidget(data);
    } else {
      this.getFlux().actions.createWidget(data);
    }
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

module.exports = RawHtmlWidgetForm