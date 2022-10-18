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
  'fundraiser:one_time_transaction_submitted',
  'fundraiser:monthly_transaction_submitted',
  'fundraiser:weekly_transaction_submitted',
  'fundraiser:one_time_transaction_submitted_forced_layout',
  'fundraiser:monthly_transaction_submitted_forced_layout',
  'fundraiser:weekly_transaction_submitted_forced_layout',
  'fundraiser:set_store_in_vault',
  'fundraiser:set_one_time',
  'fundraiser:set_monthly',
  'fundraiser:set_weekly',
  'fundraiser:donate_button_clicked_forced_layout',
  'change_currency',
  'set_payment_type',
  'select_amount',
  'form:select_amount',
  'change_amount',
  'action:submitted_success',
  'two_step:accept',
  'two_step:decline',
].forEach(eventName => {
  const callback = (...rest) => logEvent(eventName, ...rest);
  ee.on(eventName, callback);
});

$(() => {
  ee.emit('page:arrived');
});
