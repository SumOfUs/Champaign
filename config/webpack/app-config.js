require('dotenv').config({ path: 'env.yml' });
const webpack = require('webpack');

module.exports = {
  plugins: [],
  externals: {
    backbone: 'window.Backbone',
    jquery: 'window.$',
    lodash: 'window._',
  },
};
