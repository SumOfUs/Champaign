CheckBox = React.createClass({
  getInitialState() {
    return (
      { checked: this.props.checked }
    )
  },

  handleChange() {
    checked = React.findDOMNode(this.refs.checkbox).checked

    data = {}
    data[this.props.name] = checked
    this.props.onChange(data);
    this.setState( {checked: !this.state.checked } )
  },

  render() {
    return (
      <div className="checkbox">
        <label htmlFor="campaign_page_{this.props.label}" className="control-label">
          <input type="checkbox" checked={this.state.checked } onChange={ this.handleChange } ref="checkbox" /> {this.props.label}
        </label>
      </div>
    )
  }
})


CampaignPageForm = React.createClass({
  render() {
    return(
      <div className="form-group">
        <label htmlFor="campaign_page_title" className="control-label">Title</label>
        <input value={ this.props.title } type="text" id="campaign_page_title" className="form-control" name="campaign_page[title]" ref="title" />
      </div>
    )
  }
})


TextBodyWidget = React.createClass({
  handleSubmit(e){
    e.preventDefault()
  },

  render() {
    return(
      <form onSubmit={this.handleSubmit}>
        <label>Body</label>
        <textarea></textarea>
      </form>
    )
  }
})


EditCampaignPage = React.createClass({
  getInitialState() {
    return {
      featured: this.props.featured,
      active: this.props.active
    }
  },

  handleSubmits(data) {
    url = "/campaign_pages/" + this.props.id + ".json"
    $.ajax({
      url: url,
      dataType: 'json',
      type: 'PUT',
      data: { campaign_page: data }
    }).done( function(data) {
      console.log(data);
     }
    )
  },

  render() {
    return (
      <div>
      <form onSubmit={this.handleSubmit}>
        <CampaignPageForm title={this.props.title} />
        <CheckBox onChange={this.handleSubmits} name='featured' label='Featured' checked={this.state.featured}/>
        <CheckBox onChange={this.handleSubmits} name='active' label='Active' checked={this.state.active}/>
      </form>
      <div id="new-widget"></div>
      </div>
    );
  }
})




