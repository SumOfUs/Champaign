import $ from 'jquery';

$(() => {
  // const version = ['fat_checkbox','skinny_checkbox'][Math.round(Math.random())];
  const version = 'skinny_checkbox';

  $.subscribe('petition:arrived', (event, data) => {
    const { member, page } = data;

    console.log('arrived');
    mixpanel.track('petition:arrived', {
      page: page.title,
      new_user: Object.keys(member).length == 0,
      version: version,
    });
  });

  $.subscribe('petition:submit:success', (event, data) => {
    const { page } = data;

    mixpanel.track('petition:submit:success', {
      page: page.title,
      version: version,
    });
  });

  $.subscribe('share:two-step:accept', (_, data) => {
    console.log('hello');
    const { page } = data;

    mixpanel.track('share:two-step:accept', {
      page: page.title,
      version: version,
    });
  });

  $.subscribe('share:two-step:decline', (_, data) => {
    const { page } = data;

    mixpanel.track('share:two-step:decline', {
      page: page.title,
      version: version,
    });
  });
});
