var Fluxxor = require('fluxxor');

var events = {
  UPDATE_CAMPAIGN_PAGE:  "UPDATE_CAMPAIGN_PAGE",
}

var CampaignPageStore = Fluxxor.createStore({

  initialize: function(){
    this.campaign_page = {};

    this.bindActions(
      events.UPDATE_CAMPAIGN_PAGE,  this.onUpdateCampaignPage
    );
  },

  onUpdateCampaignPage: function(data) {
    this.campaign_page = data;
    this.emit("change");
  }
});

module.exports = {
  store: CampaignPageStore,
  events: events
}
