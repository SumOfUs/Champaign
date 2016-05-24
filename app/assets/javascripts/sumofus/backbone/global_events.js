const GlobalEvents = {
  bindEvents(view) {
    const events = view.globalEvents;
    if (!events || !_.isObject(events)) return;
    for (var eventName in events) {
      const methodName = events[eventName]
      const method = view[methodName];
      if (method) {
        Backbone.on(eventName, method, view);
      }
    }
  },
};

module.exports = GlobalEvents;
