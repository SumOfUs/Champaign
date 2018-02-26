export const logEvent = (eventName, payload) => {
  if (typeof mixpanel === 'undefined') return;
  if (typeof champaign === 'undefined') return;

  const opts = {
    page: champaign.page.slug,
    plugins: champaign.page.plugins,
    layout: champaign.page.layout,
    follow_up_layout: champaign.page.follow_up_layout,
    new_member: !Object.keys(champaign.personalization.member).length,
    ...payload,
  };

  if (window.TRACK_USER_ACTIONS) mixpanel.track('champaign:' + eventName, opts);
};
