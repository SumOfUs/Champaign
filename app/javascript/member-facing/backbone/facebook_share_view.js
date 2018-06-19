import _ from 'lodash';
import Backbone from 'backbone';
import FacebookShareModel from './facebook_share_model';
import SweetPlaceholder from './sweet_placeholder';

const FacebookShareView = Backbone.View.extend({
  el: '#facebook_share-container',

  events: {
    'click input[type="checkbox"]': 'handleClick',
    'change textarea': 'updateMessage',
  },

  trackEvent(name) {
    ga(
      'send',
      'event',
      'fb:sign_share',
      name,
      window.champaign.personalization.urlParams.id
    );
  },

  initialize() {
    this.fbConnected = false;
    this.template = _.template(this.$('script').html());
    this.fbAppId = $("meta[property='fb:app_id']").attr('content');
    this.trackEvent('landed_on_page');
    this.model = new FacebookShareModel(this.fbShareData());
    this.initializeFbClient();
  },

  fbShareData() {
    return {
      description: $("meta[property='og:description']").attr('content'),
      title: $("meta[property='og:title']").attr('content'),
      image: $("meta[property='og:image:url']").attr('content'),
      url: $("meta[property='og:url']").attr('content'),
    };
  },

  initializeFbClient() {
    $.ajaxSetup({ cache: true });

    $.getScript('//connect.facebook.net/en_US/sdk.js', () => {
      FB.init({
        appId: `${this.fbAppId}`,
        version: 'v2.7',
      });

      FB.getLoginStatus(response => {
        if (response.status === 'connected') {
          this.processConnected();
        } else {
          this.model.disable();
          this.render();
        }
      });
    });
  },

  processConnected() {
    let permitted = false;
    FB.api('/me/permissions', response => {
      _.forEach(response.data, function(item) {
        if (
          item.permission === 'publish_actions' &&
          item.status === 'granted'
        ) {
          permitted = true;
        }
      });
      if (permitted) {
        this.fbConnected = true;
      } else {
        this.model.disable();
        this.render();
      }
    });
  },

  post(cb) {
    if (this.model.isEnabled()) {
      this.model.post(FB, () => {
        this.trackEvent('shared');

        if (this.model.get('message') !== '') {
          this.trackEvent('custom_comment');
        }

        cb();
      });
    } else {
      cb();
    }
  },

  updateMessage(e) {
    this.model.set('message', e.target.value);
  },

  handleClick() {
    const loginHandler = resp => {
      if (
        resp.status !== 'connected' ||
        resp.authResponse.grantedScopes.indexOf('publish_actions') === -1
      ) {
        this.model.disable();
        this.render();
        this.fbConnected = false;
        this.trackEvent('aborts_authorisation');
      } else {
        this.trackEvent('authorised');
      }
    };

    const checked = this.$('input[type="checkbox"]').prop('checked');
    const options = { scope: 'publish_actions', return_scopes: true };

    if (checked) {
      this.trackEvent('enabled');
      if (!this.fbConnected) FB.login(loginHandler, options);
      this.model.enable();
    } else {
      this.trackEvent('disabled');
      this.model.disable();
    }
  },

  check() {
    this.$el.prop('checked', true);
  },

  render() {
    this.$el.html(this.template(this.model.toJSON()));
    new SweetPlaceholder(this.$('.sweet-placeholder__field'));
    return this;
  },
});

FacebookShareView.isAvailable = () => {
  return !!$('#facebook_share-container').length;
};

export default FacebookShareView;
