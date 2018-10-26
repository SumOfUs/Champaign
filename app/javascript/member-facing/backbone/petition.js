// @flow
import Backbone from 'backbone';
import ee from '../../shared/pub_sub';
import GlobalEvents from '../../shared/global_events';
import FacebookShareView from './facebook_share_view';
import I18n from 'champaign-i18n';

const Petition = Backbone.View.extend({
  el: '.petition-bar',

  globalEvents: {
    'form:submitted': 'handleSuccess',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    submissionCallback: callback with event and server data for successful submission
  //    redirectAfterAction: when true it redirects to the follow up page, defaults to true
  initialize(options = {}) {
    this.followUpUrl = options.followUpUrl;
    this.submissionCallback = options.submissionCallback;
    this.skipOnSuccessAction = options.skipOnSuccessAction;

    if (options.redirectAfterAction !== undefined) {
      this.redirectAfterAction = options.redirectAfterAction;
    } else {
      this.redirectAfterAction = true;
    }

    GlobalEvents.bindEvents(this);

    if (FacebookShareView.isAvailable()) {
      this.facebookShareView = new FacebookShareView().render();
    }
  },

  handleSuccess(e, data) {
    ee.emit('petition:submitted');

    if (this.skipOnSuccessAction) {
      return;
    }

    const hasCallbackFunction = typeof this.submissionCallback === 'function';

    if (hasCallbackFunction) {
      this.submissionCallback(e, data);
    }

    const handleRedirect = () => {
      if (data && data.follow_up_url) {
        this.redirectTo(data.follow_up_url);
      } else if (this.followUpUrl) {
        this.redirectTo(this.followUpUrl);
      } else if (!hasCallbackFunction) {
        // only do this option if no redirect or callback supplied
        alert(I18n.t('petition.excited_confirmation'));
      }
    };

    if (this.facebookShareView) {
      this.facebookShareView.post(handleRedirect.bind(this));
    } else if (this.redirectAfterAction) {
      handleRedirect();
    }
  },

  redirectTo(url) {
    window.location.href = url;
  },
});

export default Petition;
