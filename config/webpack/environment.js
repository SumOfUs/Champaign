const { environment } = require('@rails/webpacker');
const _ = require('lodash');
const dotenv = require('dotenv');
const webpack = require('webpack');
const custom = require('./custom.js');

Object.assign(process.env, dotenv.config().parsed);

environment.config.merge(custom);

environment.plugins.append(
  'Environment',
  new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env)))
);

module.exports = environment;
