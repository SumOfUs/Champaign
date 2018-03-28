const environment = require('./environment');

const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
environment.plugins.delete('UglifyJs');
environment.plugins.set(
  'UglifyJs',
  new UglifyJSPlugin({
    uglifyOptions: {
      ecma: 5,
    },
  })
);

module.exports = environment.toWebpackConfig();
