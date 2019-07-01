const { environment } = require('@rails/webpacker');
const webpack = require('webpack');
const WebpackAssetsManifest = require('webpack-assets-manifest');
const dotenv = require('dotenv');
const typescript = require('./loaders/typescript');
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
environment.loaders.prepend('typescript', typescript);
environment.plugins.prepend(
  'Environment',
  new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env)))
);
environment.plugins.append(
  'WebpackAssetsManifest',
  new WebpackAssetsManifest()
);
environment.splitChunks();

module.exports = environment;
