const webpack = require('webpack');

module.exports = {
  plugins: [],
  externals: {
    'champaign-i18n': 'window.I18n',
  },
  resolve: {
    alias: {
      underscore: 'lodash',
    },
  },
};
