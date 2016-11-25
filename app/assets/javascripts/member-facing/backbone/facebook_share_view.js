const FacebookShareModel = require('./facebook_share_model');
const SweetPlaceholder = require('./sweet_placeholder');
const mixpanel = require('mixpanel-browser');

const FacebookShareView = Backbone.View.extend({
  el: '#facebook_share-container',

  events: {
    'click input[type="checkbox"]' : 'handleClick',
    'change textarea' : 'updateMessage',
  },

  initialize() {
    mixpanel.init( window.champaign.personalization.mixpanel_token );

    this.template =  _.template(this.$('script').html());

    this.fbAppId = $("meta[property='fb:app_id']").attr('content');

    this.model = new FacebookShareModel({
      path: window.location.pathname,
      origin: window.location.origin,
    });

    this.model.bind('change', this.render.bind(this));
    this.initializeFbClient();
  },

  initializeFbClient() {
    $.ajaxSetup({ cache: true });

    $.getScript('//connect.facebook.net/en_US/sdk.js', () => {
      FB.init({
        appId: `${this.fbAppId}`,
        version: 'v2.7',
      });

      if(this.model.isEnabled()) {
        FB.getLoginStatus( (response) => {
          if(response.status !== 'connected'){
            this.model.disable();
          }
        });
      }
    }.bind(this));
  },

  post(cb) {
    if( this.model.isEnabled() ) {
      this.model.post(FB, () => {
        mixpanel.track("FBSS:SHARE", { page: this.model.get('path') }, cb);
      });
    } else {
      cb();
    }
  },

  updateMessage(e) {
    this.model.set('message', e.target.value);
  },

  handleClick() {
    const checked =  this.$('input[type="checkbox"]').prop('checked');

    if(checked) {
      this.loginToFb();
      this.model.enable();
    } else {
      this.model.disable();
    }
  },

  loginToFb() {
    FB.getLoginStatus( (response) => {
      if(response.status !== 'connected'){
        const options = { scope: 'publish_actions' };

        const loginHandler = (resp) => {
          if(resp.status !== 'connected') {
            this.model.disable();
            mixpanel.track("FBSS:LOGIN", {sucess: false });
          } else {
            mixpanel.track("FBSS:LOGIN", {sucess: true });
          }
        };

        FB.login( loginHandler, options );
      }
    });
  },

  check(){
    this.$el.prop('checked', true);
  },

  render() {
    this.$el.html( this.template( this.model.toJSON() ) );
    new SweetPlaceholder(this.$('.sweet-placeholder__field'));
    return this;
  },
});

FacebookShareView.isAvailable = () => {
  return !!$('#facebook_share-container').length;
};

module.exports = FacebookShareView;
