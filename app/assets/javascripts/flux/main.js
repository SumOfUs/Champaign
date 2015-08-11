var Fluxxor      = require('fluxxor');
var WidgetStore  = require('flux/widget_store');
var WidgetClient = require('flux/widget_client');
var CampaignPageStore  = require('flux/campaign_page_store');
var CampaignPageClient = require('flux/campaign_page_client');

var actions = {
  loadWidgets: function(data){
    WidgetClient.load(data, function(resp){
      this.dispatch(WidgetStore.events.LOAD_WIDGETS, {widgets: resp});
    }.bind(this))
  },

  updateWidget: function(data) {
    WidgetClient.update(data, function(resp) {
      this.dispatch(WidgetStore.events.UPDATE_WIDGET, data);
    }.bind(this), function(resp){
      this.dispatch(WidgetStore.events.UPDATE_WIDGET_FAIL, {errors: resp.responseJSON, data: data});
    }.bind(this));
  },

  createWidget: function(data) {
    WidgetClient.create(data, function(resp) {
      data.id = resp.id
      this.dispatch(WidgetStore.events.CREATE_WIDGET, data);
    }.bind(this), function(resp){
      this.dispatch(WidgetStore.events.CREATE_WIDGET_FAIL, {errors: resp.responseJSON, data: data});
    }.bind(this));
  },

  destroyWidget: function(data){
    WidgetClient.destroy(data, function(resp) {
      this.dispatch(WidgetStore.events.DESTROY_WIDGET, data);
    }.bind(this));
  },

  setPageMetadata: function(data){
    this.dispatch(WidgetStore.events.SET_PAGE_METADATA, data);
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