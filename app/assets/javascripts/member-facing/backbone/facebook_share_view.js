const FacebookShareModel = require('./facebook_share_model');
const SweetPlaceholder = require('./sweet_placeholder');

const FacebookShareView = Backbone.View.extend({
  el: '#facebook_share-container',

  events: {
    'click input[type="checkbox"]' : 'handleClick',
    'change textarea' : 'updateMessage',
  },

  initialize() {
    this.fbConnected = false;
    this.template =  _.template(this.$('script').html());
    this.fbAppId = $("meta[property='fb:app_id']").attr('content');

    this.model = new FacebookShareModel(this.fbShareData());
    this.initializeFbClient();
  },

  fbShareData() {
    return {
      description: $("meta[property='og:description']").attr('content'),
      title: $("meta[property='og:title']").attr('content'),
      image: $("meta[property='og:image:url']").attr('content'),
      url: $("meta[property='og:url']").attr('content'),
    }
  },

  initializeFbClient() {
    $.ajaxSetup({ cache: true });

    $.getScript('//connect.facebook.net/en_US/sdk.js', () => {
      FB.init({
        appId: `${this.fbAppId}`,
        version: 'v2.7',
      });

      FB.getLoginStatus( (response) => {
        if(response.status === 'connected'){
          this.processConnected();
        } else {
          this.model.disable();
          this.render();
        }
      }.bind(this));
    });
  },

  processConnected() {
    let permitted = false;
    FB.api('/me/permissions', (response) => {
      _.forEach(response.data, function(item){
        if(item.permission === 'publish_actions' && item.status === 'granted') {
          permitted = true;
        }
      });
      if(permitted) {
        this.fbConnected = true;
      } else {
        this.model.disable();
        this.render();
      }
    }.bind(this));
  },

  post(cb) {
    if( this.model.isEnabled() ) {
      this.model.post(FB, () => {
        ga('send', 'event', 'fb:sign_share', 'shared');

        if(this.model.get('message') !== ''){
          ga('send', 'event', 'fb:sign_share', 'custom_comment');
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
    const loginHandler = (resp) => {
      if(resp.status !== 'connected' || resp.authResponse.grantedScopes.indexOf('publish_actions') === -1) {
        this.model.disable();
        this.render();
        this.fbConnected = false;
        ga('send', 'event', 'fb:sign_share', 'aborts_authorisation');
      } else {
        ga('send', 'event', 'fb:sign_share', 'authorised');
      }
    };

    const checked =  this.$('input[type="checkbox"]').prop('checked');
    const options = { scope: 'publish_actions', return_scopes: true };

    if(checked) {
      ga('send', 'event', 'fb:sign_share', 'enabled');
      if(!this.fbConnected) FB.login( loginHandler, options );
      this.model.enable();
    } else {
      ga('send', 'event', 'fb:sign_share', 'disabled');
      this.model.disable();
    }
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
