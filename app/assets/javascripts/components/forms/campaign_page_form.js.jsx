var CheckBox = require('components/ui/check_box')

var CampaignPageForm = React.createClass({
  render() {
    return(
      <div className="form-group">
        <label htmlFor="campaign_page_title" className="control-label">Title</label>
        <input defaultValue={ this.props.title } type="text" id="campaign_page_title" className="form-control" name="campaign_page[title]" ref="title" />
      </div>
    )
  }
})

var EditCampaignPage = React.createClass({
  getInitialState() {
    return {
      featured: this.props.featured,
      active: this.props.active
    }
  },

  handleSubmits(data) {
    let url = "/campaign_pages/" + this.props.id + ".json"
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

module.exports = EditCampaignPage;
