import Cookie from 'js-cookie';
import { Model } from 'backbone';

const FacebookShareModel = Model.extend({
  defaults: {
    name: '',
    message: '',
    enabled: Cookie.get('facebookShare') === '1',
  },

  feedOptions() {
    return {
      message: this.get('message'),
      link: this.buildLink(),
      caption: I18n.t('facebook_share.caption'),
      image: this.get('image'),
      title: this.get('title'),
      description: this.get('description'),
    };
  },

  post(client, cb) {
    const options = this.feedOptions();

    client.api('/me/feed', 'post', options, response => {
      if (!response || response.error) {
        console.log(response);
      }

      cb();
    });
  },

  buildLink() {
    return `${this.get('url')}?source=fbexpress`;
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
});

export default FacebookShareModel;
