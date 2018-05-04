import Raven from 'raven-js';
import $ from 'jquery';

Raven.config(process.env.SENTRY_DSN, {
  release: process.env.CIRCLE_SHA1,
  dataCallback: data => {
    addReduxState(data);
    console.log('sentry data:', data);
    return data;
  },
}).install();

function addReduxState(data) {
  if (window.champaign.store) {
    data.extra = {
      ...data.extra,
      reduxState: window.champaign.store.getState(),
    };
  }
}
