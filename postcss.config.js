module.exports = webpack => ({
  plugins: [
    require('postcss-import')({}),
    require('postcss-cssnext')({
      browserlist: ['> 0.07% in my stats'],
    }),
  ],
});
