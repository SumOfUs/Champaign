const cssnext = require('postcss-cssnext');
const smartImport = require('postcss-smart-import');

module.exports = webpack => ({
  plugins: [
    require('postcss-smart-import')({
      addDependencyTo: webpack,
    }),
    require('postcss-cssnext')({
      browserlist: ['> 0.07% in my stats'],
    }),
  ],
});
