var mixins = require('flux/mixins');

var TextBodyWidgetForm = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number
  },

  mixins: [mixins.FluxMixin],

  handleSubmit(e) {
    e.preventDefault()
    var text = React.findDOMNode(this.refs.body).value
    var data = {text_body_html: text, text: text, type: 'TextBodyWidget', campaign_page_id: this.props.campaign_page_id }
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