import ErrorDisplay from '../shared/show_errors';

$(() => {
  $('form.registration-form').on('ajax:error', (e, xhr) =>
    ErrorDisplay.show(e, xhr)
  );
});
