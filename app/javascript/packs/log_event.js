export const logEvent = (eventName, payload) => {
  const opts = {
    page: champaign.page.slug,
    plugins: champaign.page.plugins,
    layout: champaign.page.layout,
    follow_up_layout: champaign.page.follow_up_layout,
    new_member: !Object.keys(champaign.personalization.member).length,
    ...payload,
  };

  // amplitude.logEvent('champaign:' + eventName, payload);
  mixpanel.track('champaign:' + eventName, opts);
};
