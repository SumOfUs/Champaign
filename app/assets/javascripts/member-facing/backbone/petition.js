const GlobalEvents = require('shared/global_events');

const Petition = Backbone.View.extend({

  el: '.petition-bar',

  globalEvents: {
    'form:submitted': 'handleSuccess',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    submissionCallback: callback with event and server data for successful submission
  initialize(options = {}) {
    this.followUpUrl = options.followUpUrl;
    this.submissionCallback = options.submissionCallback;
    this.skipOnSuccessAction = options.skipOnSuccessAction;
    GlobalEvents.bindEvents(this);
  },

  handleSuccess(e, data) {
    $.publish('petition:submitted');
    if(this.skipOnSuccessAction) {
      return;
    }
    let hasCallbackFunction = (typeof this.submissionCallback === 'function');
    if (hasCallbackFunction) {
      this.submissionCallback(e, data);
    }
    if (data && data.follow_up_url) {
      this.redirectTo(data.follow_up_url);
    } else if (this.followUpUrl) {
      this.redirectTo(this.followUpUrl);
    } else if(!hasCallbackFunction) {
      // only do this option if no redirect or callback supplied
      alert(I18n.t('petition.excited_confirmation'));
    }
  },

  redirectTo(url) {
    window.location.href = url;
  },

});

module.exports = Petition;
