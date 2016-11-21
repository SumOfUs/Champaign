const Cookie = require( "js-cookie" );

const FacebookShareModel = Backbone.Model.extend({
  defaults: {
    name: '',
    message: '',
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
    return `${this.get('origin')}${this.get('path')}`;
  },

  isEnabled() {
    const state = Cookie.get('facebookShare');
    return window.parseInt(state) === 1;
  },

  enable() {
    Cookie.set('facebookShare', 1);
  },

  disable() {
    Cookie.set('facebookShare', 0);
  },

  forTemplate() {
    return {
      enabled: this.isEnabled(),
      name: this.get('name')
    }
  }
});

module.exports = FacebookShareModel;
