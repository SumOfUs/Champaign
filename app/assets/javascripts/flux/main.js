var Fluxxor      = require('fluxxor');
var WidgetStore  = require('flux/widget_store');
var WidgetClient = require('flux/widget_client');
var CampaignPageStore  = require('flux/campaign_page_store');
var CampaignPageClient = require('flux/campaign_page_client');

var actions = {
  loadWidgets: function(){
    WidgetClient.load( function(data){
      this.dispatch(WidgetStore.events.LOAD_WIDGETS, {widgets: data});
    }.bind(this))
  },

  updateWidget: function(data) {
    WidgetClient.update(data, function(resp) {
      this.dispatch(WidgetStore.events.UPDATE_WIDGET, data);
    }.bind(this));
  },

  createWidget: function(data) {
    WidgetClient.create(data, function(resp) {
      data.id = resp.id
      this.dispatch(WidgetStore.events.CREATE_WIDGET, data);
    }.bind(this));
  },

  destroyWidget: function(id){
    WidgetClient.destroy(id, function(resp) {
      this.dispatch(WidgetStore.events.DESTROY_WIDGET, id);
    }.bind(this));
  },

  updateCampaignPage: function(data) {
    CampaignPageClient.update(data, function(resp) {
      this.dispatch(CampaignPageStore.events.UPDATE_CAMPAIGN_PAGE, data);
    }.bind(this));
  }
};

var stores = {
  WidgetStore: new WidgetStore.store(),
  CampaignPageStore: new CampaignPageStore.store()
};

var flux = new Fluxxor.Flux(stores, actions);

module.exports = flux;