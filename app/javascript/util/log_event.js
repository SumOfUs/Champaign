// @flow
const uuid = require('uuid/v1');

export const logEvent = (eventName: string, ...payload: any) => {
  if (typeof window.mixpanel === 'undefined') return;
  if (typeof window.champaign === 'undefined') return;

  const opts = {
    page: window.champaign.page.slug,
    plugins: window.champaign.page.plugins,
    layout: window.champaign.page.layout,
    follow_up_layout: window.champaign.page.follow_up_layout,
    new_member: !Object.keys(window.champaign.personalization.member).length,
    ...payload,
  };

  if (window.TRACK_USER_ACTIONS) window.mixpanel.track(eventName, opts);

  if (window.ga) logToGa(eventName, ...payload);
};

const getEventData = (eventName: string, ...data: any) => {
  switch (eventName) {
    case 'action:submitted_success':
      return ['action', 'submitted_success'];
    case '@@chmp:consent:change_country':
      return ['gdpr', 'change_country', data[0].countryCode];
    case '@@chmp:consent:change_consent':
      return ['gdpr', 'change_consent', data[0].consented ? 'true' : 'false'];
    case 'change_amount':
      return [
        'fundraising',
        'change_amount',
        null,
        parseFloat(data[0].payload),
      ];
    case 'set_store_in_vault':
      return [
        'fundraising',
        'set_store_in_vault',
        data[0].payload ? 'true' : 'false',
      ];
    case 'set_recurring':
      return [
        'fundraising',
        'set_recurring',
        data[0].payload ? 'true' : 'false',
      ];
    case 'fundraiser:transaction_submitted':
      if (window.ga) logEcommerce(data);
      return [
        'fundraising',
        'transaction_submitted',
        null,
        parseFloat(data[0].value),
      ];
    case 'change_step':
      return ['fundraising', 'change_step', data[0].payload];
    case 'change_currency':
      return ['fundraising', 'change_currency', data[0].payload];
    case 'set_payment_type':
      return ['fundraising', 'set_payment_type', data[0].payload];
    case 'social_share':
      return ['social_share', 'shared_on_' + data[0].share_type];
    default:
      return false;
  }
};

const logToGa = (eventName: string, data: any) => {
  const eventData = getEventData(eventName, data);

  if (eventData) {
    window.ga('send', 'event', ...eventData);
  }
};

const logEcommerce = data => {
  const UUID = uuid();
  window.ga('ecommerce:addTransaction', {
    id: UUID,
    revenue: data[0].value,
    currency: data[0].currency,
  });

  window.ga('ecommerce:addItem', {
    id: UUID,
    name: data[0].recurring == true ? 'recurring' : 'one-time',
    category: data[0].content_category,
    price: data[0].value,
    quantity: 1,
    currency: data[0].currency,
  });
};
