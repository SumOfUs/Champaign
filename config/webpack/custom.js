const webpack = require('webpack');

module.exports = {
  externals: [
    /* Replace any jquery import/require statements for the global `$` object,
     * except for imports in the vendor context. This means that any file under
     * app/javascript/vendor that requires jquery will be served the jquery
     * module from `node_modules`, whilst all other requests for jquery will be
     * served with the `$` global (window.$).
     * Backbone does a require('jquery'), so now it gets replaced with window.$
     * along with any plugins we've attached to the global jquery.
     * See app/javascript/packs/globals.js to see what we're doing with this.
     */
    function(context, request, callback) {
      const isJqueryRequest = /^jquery$/.test(request);
      const isVendorContext = /javascript\/vendor$/.test(context);
      if (isJqueryRequest) {
        return isVendorContext ? callback() : callback(null, 'var window.$');
      }
      callback();
    },
    {
      'champaign-i18n': 'window.I18n',
    },
  ],
  resolve: {
    alias: {
      // Replace underscore with lodash to avoid bundling both. Backbone requires
      // underscore, so now it's using lodash.
      underscore: 'lodash',
    },
  },
};
