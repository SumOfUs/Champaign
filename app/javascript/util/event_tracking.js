// @flow
import $ from 'jquery';
import ee from '../shared/pub_sub';
import { logEvent } from './log_event';

[
  'page:arrived',
  'form:update',
  'member:set',
  'member:reset',
  'petition:submitted',
  'fundraiser:transaction_submitted',
  'consent:change_consent',
].forEach(eventName => {
  const callback = (e, ...rest) => logEvent(eventName, ...rest);
  ee.on(eventName, callback);
});

$(() => {
  ee.emit('page:arrived');
});
