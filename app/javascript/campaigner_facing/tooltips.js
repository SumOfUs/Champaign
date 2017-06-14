import $ from 'jquery';

$.subscribe('pages:new pages:edit form:edit pages:analytics', function() {
  console.log('pages:edit was triggered');
  $('[data-toggle="tooltip"]').tooltip();
});
