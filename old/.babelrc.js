module.exports = {
  presets: [
    [
      '@babel/preset-env',
      {
        useBuiltIns: 'entry',
      },
    ],
    '@babel/preset-typescript',
    '@babel/preset-react',
  ],
  plugins: [
    'syntax-dynamic-import',
    'transform-object-rest-spread',
    [
      'transform-class-properties',
      {
        spec: true,
      },
    ],
  ],
  env: {
    test: {
      plugins: ['transform-es2015-modules-commonjs'],
    },
  },
};
