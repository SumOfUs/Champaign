const webpack = require('webpack');

module.exports = {
  externals: {
    'champaign-i18n': 'window.I18n',
    jquery: 'window.jQuery',
  },

  resolve: {
    alias: {
      // Replace underscore with lodash to avoid bundling both. Backbone requires
      // underscore, so now it's using lodash.
      underscore: 'lodash',
    },
  },
};
