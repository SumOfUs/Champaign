var Fluxxor = require('fluxxor');

var mixins = {
  FluxMixin: Fluxxor.FluxMixin(React),
  StoreWatchMixin: Fluxxor.StoreWatchMixin
}

module.exports = mixins;