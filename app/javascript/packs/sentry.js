// @flow
import Raven from 'raven-js';

function addUserData(data) {
  if (!window.champaign) return;
  if (!window.champaign.personalization) return;
  const { location, member } = window.champaign.personalization;
  data.user = {
    id: member ? member.id : undefined,
    username: member ? member.name : undefined,
    ip: location ? location.ip : undefined,
  };
}

function addReduxState(data) {
  if (window.champaign && window.champaign.store) {
    data.extra = {
      ...data.extra,
      reduxState: window.champaign.store.getState(),
    };
  }
}

Raven.config(process.env.SENTRY_DSN, {
  release: process.env.BUILD_TIME || process.env.CIRCLE_SHA1,
  environment: process.env.SENTRY_ENVIRONMENT || 'development',
  dataCallback: data => {
    addUserData(data);
    addReduxState(data);
    return data;
  },
}).install();

window.Raven = Raven;
