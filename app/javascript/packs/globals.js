// @flow
import $ from '../vendor/jquery';
import _ from '../vendor/lodash';
import ee from '../shared/pub_sub';
import 'selectize/dist/css/selectize.default.css';

window.$ = window.jQuery = $;
window._ = _;

if (!window.ee) window.ee = ee;

function $subscribe(eventName: string, callback: (...args: mixed) => any) {
  // to maintain backwards compatibility, jQuery events always
  // pass the event object as the first parameter. We don't have it
  const compatibleCallback = function(...args) {
    callback(this, ...args);
  };
  ee.on(eventName, compatibleCallback);
}

function $publish(eventName: string, ...args: any) {
  ee.emit(eventName, ...args);
}

_.extend($, {
  publish: $publish,
  subscribe: $subscribe,
});

// jQuery plugins
require('jquery-ui');
require('jquery-ujs');
require('selectize');
require('jquery-sticky');
