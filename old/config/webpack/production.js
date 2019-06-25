const environment = require('./environment');

const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
environment.plugins.delete('UglifyJs');
environment.plugins.append(
  'UglifyJs',
  new UglifyJSPlugin({
    sourceMap: false,
    uglifyOptions: {
      ecma: 5,
    },
  })
);

module.exports = environment.toWebpackConfig();
