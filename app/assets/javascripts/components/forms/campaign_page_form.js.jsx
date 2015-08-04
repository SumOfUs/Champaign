var CheckBox = require('components/ui/check_box');
var flux     = require('flux/main');
var mixins   = require('flux/mixins');

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
  mixins: [mixins.FluxMixin],

  getInitialState() {
    return {
      featured: this.props.featured,
      active: this.props.active
    }
  },

  getDefaultProps() {
    return { flux: flux };
  },

  handleSubmits(data) {
    this.getFlux().actions.updateCampaignPage(data);
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
