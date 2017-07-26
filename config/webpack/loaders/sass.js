const ExtractTextPlugin = require('extract-text-webpack-plugin');
const { env } = require('../configuration.js');

const development = [
  'style-loader',
  {
    loader: 'css-loader',
    options: {
      importLoaders: true,
      minimize: false,
    },
  },
  'postcss-loader',
  'sass-loader',
];

const production = ExtractTextPlugin.extract({
  fallback: 'style-loader',
  use: [
    {
      loader: 'css-loader',
      options: {
        importLoaders: true,
        minimize: true,
      },
    },
    {
      loader: 'postcss-loader',
      options: { sourceMap: true },
    },
    'resolve-url-loader',
    {
      loader: 'sass-loader',
      options: { sourceMap: true },
    },
  ],
});

module.exports = {
  test: /\.(scss|sass|css)$/i,
  use: process.env.NODE_ENV === 'development' ? development : production,
};
