import { logEvent } from './../packs/log_event';
import ee from '../shared/pub_sub';
import $ from 'jquery';

[
  'page:arrived',
  'form:update',
  'member:set',
  'member:reset',
  'petition:submitted',
  'fundraiser:transaction_submitted',
].forEach(eventName => {
  const callback = (e, ...rest) => logEvent(eventName, ...rest);
  ee.on(eventName, callback);
});

$(() => {
  ee.emit('page:arrived');
});
