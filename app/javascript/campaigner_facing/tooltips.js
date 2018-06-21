// @flow
import $ from 'jquery';
import ee from '../shared/pub_sub';

const initializeTooltips = () => {
  // $FlowIgnore
  $('[data-toggle="tooltip"]').tooltip();
};

ee.on('pages:new', initializeTooltips);
ee.on('pages:edit', initializeTooltips);
ee.on('form:edit', initializeTooltips);
ee.on('pages:analytics', initializeTooltips);
