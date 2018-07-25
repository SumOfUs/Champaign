// @flow
export const logEvent = (eventName: string, payload: any) => {
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

  if (window.TRACK_USER_ACTIONS)
    window.mixpanel.track('champaign:' + eventName, opts);


  if (window.ga)
    window.ga(
      'send',
      'event',
      'champaign',
      eventName,
      window.champaign.page.slug
      );
};
