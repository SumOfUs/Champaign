var WidgetsBox = React.createClass({
  render() {
    return (
      <div>
        <div>WidgetsBox for { this.props.campaign_page_id }</div>
        <WidgetTextForm />
      </div>
    )
  }
})

var WidgetTextForm = React.createClass({
  handleSubmit(e) {
    e.preventDefault()
    
  },

  render() {
    return (
      <form onSubmit={ this.handleSubmit }>
        <div className="form-group">
          <label for="">Text</label>
          <textarea className='form-control' ref='body'></textarea>
        </div>
        <button type="submit" className="btn btn-default">Submit</button>
      </form>
    )
  }
})
