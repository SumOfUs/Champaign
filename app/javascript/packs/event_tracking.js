const logEvent = (eventName, props = {}) => {
  const payload = {
    page: champaign.page.slug,
    plugins: champaign.page.plugins,
    layout: champaign.page.layout,
    follow_up_layout: champaign.page.follow_up_layout,
    new_member: $.isEmptyObject(champaign.personalization.member),
    ...props,
  };

  amplitude.logEvent('champaign:' + eventName, payload);
};

const subscribeEvents = amplitude => {
  [
    'page:arrived',
    'form:update',
    'member:set',
    'member:reset',
    ['fundraiser:change_amount', 'amount'],
    ['fundraiser:change_step', 'step'],
    ['fundraiser:set_recurring', 'state'],
    ['fundraiser:set_store_in_vault', 'state'],
    ['fundraiser:change_currency', 'amount'],
    ['fundraiser:set_payment_type', 'payment_type'],
    'fundraiser:transaction_success',
    'fundraiser:transaction_error',
  ].forEach(rawEvent => {
    let callback;
    let eventName = rawEvent;

    if (eventName.constructor === Array) {
      callback = (e, payload) => logEvent(e.type, { [rawEvent[1]]: payload });
      eventName = rawEvent[0];
    } else {
      callback = e => logEvent(e.type);
    }

    $.subscribe(eventName, callback);
  });
};

if (typeof window.amplitude === 'object') {
  subscribeEvents(window.amplitude);
}

$.publish('page:arrived');
