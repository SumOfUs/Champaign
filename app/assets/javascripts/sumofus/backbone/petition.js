const Petition = Backbone.View.extend({

  el: '.petition-bar',

  events: {
    'ajax:success form.action-form': 'handleSuccess',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    submissionCallback: callback with event and server data for successful submission
  //    outstandingFields: the names of step 2 form fields that aren't satisfied by
  //      the values in the member hash.
  //    member: an object with fields that will prefill the form
  //    location: a hash of location values inferred from the user's request
  //    akid: the actionkitid (akid) to save with the user request
  //    thermometer: options to display on the thermometer
  //    cosmetic: if true, then it will adjust heights and make the bar sticky scroll
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
