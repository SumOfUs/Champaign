// @flow
import $ from '../vendor/jquery';
import _ from 'lodash';
import event from '../shared/pub_sub';
import 'selectize/dist/css/selectize.default.css';

window.$ = window.jQuery = $;
window._ = _;

if (!window.event) window.event = event;

function $subscribe(eventName: string, callback: () => any) {
  // to maintain backwards compatibility, jQuery events always
  // pass the event object as the first parameter. We don't have it
  const compatibleCallback = function(...args) {
    callback(this, ...args);
  };
  event.on(eventName, compatibleCallback);
}

function $publish(eventName: string, ...args: any) {
  event.emit(eventName, ...args);
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
