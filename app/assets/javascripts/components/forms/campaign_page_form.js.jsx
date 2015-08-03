var CheckBox = require('components/ui/check_box');
var flux     = require('flux/main');
var mixins   = require('flux/mixins');
var CampaignPageStore = require('flux/campaign_page_store');


var EditCampaignPage = React.createClass({
  //mixins: [mixins.FluxMixin, mixins.StoreWatchMixin("CampaignPageStore")],
  mixins: [mixins.FluxMixin],

  getInitialState() {
    return {
      featured: this.props.featured,
      active: this.props.active,
      updating: false
    }
  },

  getDefaultProps() {
    return { flux: flux };
  },

  componentDidMount(){
    this.onChangeTimeout = null;
  },

  componentWillUpdate(a, b){
  },

  handleSubmits(data) {
    this.getFlux().actions.updateCampaignPage(data);
  },

  handleSumit(e) {
    e.preventDefault()

    console.log(this.state.title);
  },

  saveTitle() {
    let data = {title: this.state.title };
    this.getFlux().actions.updateCampaignPage(data);
  },

  handleChange: function(event) {
    this.setState({title: event.target.value});

    clearTimeout(this.onChangeTimeout);

    this.onChangeTimeout = setTimeout(function(){
      this.saveTitle();
    }.bind(this) , 1000);
  },

  render() {
    return (
      <div className='campaign-page-config'>
        <form onSubmit={this.handleSumit}>
          <div className='page-title'>
            <input onChange={ this.handleChange } defaultValue={ this.props.title } type="text" id="campaign_page_title" name="campaign_page[title]" ref="title" />
            <span className='label label-success'>Saved</span>
          </div>

          <CheckBox onChange={this.handleSubmits} name='featured' label='Featured' checked={this.state.featured}/>
          <CheckBox onChange={this.handleSubmits} name='active' label='Active' checked={this.state.active}/>
        </form>
        <div id="new-widget"></div>
      </div>
    );
  }
})

module.exports = EditCampaignPage;
