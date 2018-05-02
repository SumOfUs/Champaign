import Raven from 'raven-js';
Raven.config(process.env.SENTRY_DSN, {
  release: process.env.CIRCLE_SHA1,
}).install();
