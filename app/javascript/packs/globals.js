require('selectize/dist/js/standalone/selectize.js');
require('jquery-sticky');
import _ from 'lodash';
import 'core-js/stable';
import 'regenerator-runtime/runtime';
import 'intl';
import 'intl/locale-data/jsonp/en.js';
import 'intl/locale-data/jsonp/de.js';
import 'intl/locale-data/jsonp/fr.js';
import ee from '../shared/pub_sub';
import flatten from 'flat';
require('selectize/dist/css/selectize.css');

window._ = _;

function $subscribe(eventName, callback) {
  // to maintain backwards compatibility, jQuery events always
  // pass the event object as the first parameter. We don't have it
  const compatibleCallback = function(...args) {
    callback(this, ...args);
  };
  ee.on(eventName, compatibleCallback);
}

function $publish(eventName, ...args) {
  ee.emit(eventName, ...args);
}

_.extend(window.$, {
  publish: $publish,
  subscribe: $subscribe,
});

if (!window.ee) window.ee = ee;

if (window.I18n && window.I18n.translations) {
  window.I18n.flatTranslations = _.mapValues(
    window.I18n.translations,
    (value, key) =>
      flatten(
        _.pick(value, [
          'double_opt_in',
          'footer',
          'page',
          'basics',
          'branding',
          'recommend_pages',
          'email_pension',
          'email_tool',
          'fundraiser',
          'petition',
          'form',
          'thermometer',
          'call_tool',
          'share',
          'errors',
          'validation',
          'time',
          'reset_passwords',
          'survey',
          'reset_password_mailer',
          'facebook_share',
          'member_registration',
          'confirmation_mailer',
          'consent',
          'cookie_consent',
        ])
      )
  );
}
