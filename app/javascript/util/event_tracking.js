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
  'action:submitted_success',
].forEach(eventName => {
  const callback = (...rest) => logEvent(eventName, ...rest);
  ee.on(eventName, callback);
});

$(() => {
  ee.emit('page:arrived');
});
