import Raven from 'raven-js';
import $ from 'jquery';

Raven.config(process.env.SENTRY_DSN, {
  release: process.env.CIRCLE_SHA1,
  environment: process.env.SENTRY_ENVIRONMENT || 'development',
  dataCallback: data => {
    addReduxState(data);
    return data;
  },
}).install();

function addReduxState(data) {
  if (window.champaign && window.champaign.store) {
    data.extra = {
      ...data.extra,
      reduxState: window.champaign.store.getState(),
    };
  }
}
