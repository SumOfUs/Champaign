// @flow
import $ from 'jquery';
import ee from '../../shared/pub_sub';

const searchConfig = function() {
  $('.page-filter__reset').click(function() {
    $('select.selectize-container').map(function(index, item) {
      // $FlowIgnore
      item.selectize.clear();
    });
    $(this)
      .closest('form')
      .find('.form-control')
      .map(function(index, item) {
        $(item).val('');
      });
  });

  // $FlowIgnore
  $('#pages-table').DataTable({
    /* Disable initial sort */
    aaSorting: [],
  });
};

ee.on('search:load', searchConfig);
