// @flow
import 'babel-polyfill';
import $ from '../vendor/jquery';
import _ from '../vendor/lodash';
import ee from '../shared/pub_sub';
import 'selectize/dist/css/selectize.default.css';

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

window.$ = window.jQuery = $;
window._ = _;

if (!window.ee) window.ee = ee;
