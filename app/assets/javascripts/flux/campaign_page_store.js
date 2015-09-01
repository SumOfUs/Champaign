let Fluxxor = require('fluxxor');

let events = {
  UPDATE_CAMPAIGN_PAGE:  "UPDATE_CAMPAIGN_PAGE",
  UPDATE_CAMPAIGN_PAGE_SUCCESS: "UPDATE_CAMPAIGN_PAGE_SUCCESS"
}

let CampaignPageStore = Fluxxor.createStore({
  initialize: function(){
    this.campaign_page = {};
    this.updating = false

    this.bindActions(
      events.UPDATE_CAMPAIGN_PAGE,         this.onUpdateCampaignPage,
      events.UPDATE_CAMPAIGN_PAGE_SUCCESS, this.onUpdateCampaignPageSuccess
    );
  },

  onUpdateCampaignPage: function() {
    this.updating = true;
    console.log('on updating');
    this.emit("change");
  },

  onUpdateCampaignPageSuccess(data) {
    //this.updating = false;
    console.log('on success');
    this.campaign_page = data;
    this.emit("change");
  }
});

module.exports = {
  store: CampaignPageStore,
  events: events
}
