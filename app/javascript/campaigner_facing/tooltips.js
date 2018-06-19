// @flow
import $ from 'jquery';
import ee from '../shared/pub_sub';

ee.on('pages:new pages:edit form:edit pages:analytics', function() {
  // $FlowIgnore
  $('[data-toggle="tooltip"]').tooltip();
});
