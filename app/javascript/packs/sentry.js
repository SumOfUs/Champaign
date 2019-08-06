import * as Sentry from '@sentry/browser';

window.Sentry = Sentry;

if (process.env.CIRCLE_SHA1 && process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    release: process.env.CIRCLE_SHA1,
    environment: process.env.SENTRY_ENVIRONMENT || 'development',
    beforeSend(event) {
      addUserData(event);
      return event;
    },
  });
}

function addUserData(event) {
  if (!window.champaign) return;
  if (!window.champaign.personalization) return;
  const { location, member } = window.champaign.personalization;
  Sentry.setUser({
    id: member ? member.id : undefined,
    username: member ? member.name : undefined,
    ip: location ? location.ip : undefined,
  });
}
