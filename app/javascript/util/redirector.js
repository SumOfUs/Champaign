export const redirect = data => {
  if (data.follow_up_page) window.location.href = data.follow_up_page;
};
