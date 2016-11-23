const Cookie = require( "js-cookie" );

const FacebookShareModel = Backbone.Model.extend({
  defaults: {
    name: '',
    message: '',
    enabled: (Cookie.get('facebookShare') === '1' ),
  },

  feedOptions() {
    return {
      message: this.get('message'),
      link: this.buildLink(),
      caption: "I just signed this petition on SumOfUs.org"
    }
  },

  post(client, cb){
    const options = this.feedOptions();

    client.api('/me/feed', 'post', options, (response) => {
      if (!response || response.error) {
        console.log('error', response);
      }

      cb();
    })
  },

  buildLink() {
    return `${this.get('origin')}${this.get('path')}?source=fbexpress`;
  },

  isEnabled() {
    return this.get('enabled');
  },

  enable() {
    this.set('enabled', true);
    Cookie.set('facebookShare', 1);
  },

  disable() {
    this.set('enabled', false);
    Cookie.set('facebookShare', 0);
  },

  forTemplate() {
    return {
      enabled: this.get('enabled'),
      name: this.get('name'),
    }
  }
});

module.exports = FacebookShareModel;
