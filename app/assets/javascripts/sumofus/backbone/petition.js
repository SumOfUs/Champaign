const Petition = Backbone.View.extend({

  el: '.petition-bar',

  events: {
    'ajax:success form.action-form': 'handleSuccess',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    submissionCallback: callback with event and server data for successful submission
  initialize(options = {}) {
    this.followUpUrl = options.followUpUrl;
    this.submissionCallback = options.submissionCallback;
  },

  handleSuccess(e, data) {
    if (typeof this.submissionCallback === 'function') {
      this.submissionCallback(e, data);
    }
    if (this.followUpUrl) {
      window.location.href = this.followUpUrl;
    }
    if (!this.followUpUrl && typeof this.submissionCallback !== 'function') {
      // only do this option if no redirect or callback supplied
      alert(I18n.t('petition.excited_confirmation'));
    }
  },

});

module.exports = Petition;
