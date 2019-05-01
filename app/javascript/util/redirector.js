// @flow
type RedirectResponse = {
  follow_up_page?: string,
};
export const redirect = (data: RedirectResponse) => {
  if (data.follow_up_page) window.location.href = data.follow_up_page;
};
