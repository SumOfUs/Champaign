var RawHtmlWidget = React.createClass({

  propTypes: {
    html:             React.PropTypes.string.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  form() {
    return (
      <div className='widget-edit'>
        <RawHtmlWidgetForm {...this.props}>
        </RawHtmlWidgetForm>
      </div>
    )
  },

  display() {
    return (
      <div className='widget-show'>
        {this.props.html}
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

var RawHtmlWidgetForm = React.createClass({

  propTypes: {
    html:             React.PropTypes.string.isRequired,
    onWidgetSubmit:   React.PropTypes.func.isRequired,
    campaign_page_id: React.PropTypes.number.isRequired,
    id:               React.PropTypes.number.isRequired
  },

  handleSubmit(e) {
    e.preventDefault()
    var text = React.findDOMNode(this.refs.body).value
    var data = { widget: {html: text, text: text, type: 'RawHtmlWidget', campaign_page_id: this.props.campaign_page_id, id: this.props.id } }
    this.props.onWidgetSubmit(data);
  },

  render() {
    return (
      <div className='widget-html-form'>
         <form onSubmit={ this.handleSubmit }>
          <div className="form-group">
            <label htmlFor="">Text</label>
            <textarea className='form-control' ref='body' defaultValue={this.props.html}></textarea>
          </div>
          <button type="submit" className="btn btn-default">Submit</button>
        </form>
      </div>
    )
  }
})
