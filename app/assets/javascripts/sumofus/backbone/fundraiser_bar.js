const StickyMethods = require('sumofus/backbone/sticky_methods');

const FundraiserBar = Backbone.View.extend(_.extend(StickyMethods, {

  el: '.fundraiser-bar',

  events: {

  },

  initialize: function() {
    console.log(this.$el);
    console.log('efff')
    this.initializeSticky();
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },


}));

module.exports = FundraiserBar;
