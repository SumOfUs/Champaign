module.exports = {
  plugins: [],
  externals: {
    jquery: 'window.$',
    lodash: 'window._',
    backbone: 'window.Backbone',
    react: 'window.React',
    'react-dom': 'window.ReactDOM',
    'champaign-i18n': 'window.I18n',
  },
};
