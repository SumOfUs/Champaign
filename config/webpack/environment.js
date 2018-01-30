const { environment } = require('@rails/webpacker');
const dotenv = require('dotenv');
const webpack = require('webpack');
const custom = require('./custom.js');

const dotenvFiles = [
  `.env.${process.env.NODE_ENV}.local`,
  '.env.local',
  `.env.${process.env.NODE_ENV}`,
  '.env',
];

dotenvFiles.forEach(dotenvFile => {
  dotenv.config({ path: dotenvFile, silent: true });
});

environment.config.merge(custom);
environment.plugins.set(
  'Environment',
  new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env)))
);

module.exports = environment;
