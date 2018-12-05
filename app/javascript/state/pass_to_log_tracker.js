// @flow
import { logEvent } from '../util/log_event';
import type { AppState } from './index';
import type { Dispatch } from 'redux';

const blacklist = ['update_form'];

const blacklisted = event => blacklist.indexOf(event) > -1;

const passToLogTracker = () => (next: Dispatch<*>) => (action: {
  type: string,
  [string]: any,
}) => {
  const { type, skip_log = false, ...rest } = action;

  if (!skip_log && !blacklisted(type)) {
    logEvent(type, rest);
  }

  return next(action);
};

export default passToLogTracker;
