var TextBodyWidget = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form() {
    return (
      <div className='widget-edit'>
        <TextBodyWidgetForm {...this.props}>
        </TextBodyWidgetForm>
      </div>
    )
  },

  display() {
    return (
      <div className='widget-show'>
        {this.props.text_body_html}
      </div>
    )
  },

  render() {
    return (
      <div className="text-body-widget">
        <Widget {...this.props} form={this.form} display={this.display}>
        </Widget>
      </div>
    )
  }
})

var TextBodyWidgetForm = React.createClass({

  propTypes: {
    text_body_html:   React.PropTypes.string,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number
  },

  mixins: [FluxMixin],

  handleSubmit(e) {
    e.preventDefault()
    var text = React.findDOMNode(this.refs.body).value
    var data = {text_body_html: text, text: text, type: 'TextBodyWidget', campaign_page_id: this.props.campaign_page_id, id: this.props.id }
    this.getFlux().actions.updateWidget(data);
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
