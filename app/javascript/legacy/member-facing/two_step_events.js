import ee from '../../shared/pub_sub';

$(document).ready(function() {
  $('.two-step__decline').on('click', () => {
    ee.emit('two_step:decline');
  });

  $('.two-step__accept').on('click', () => {
    ee.emit('two_step:accept');
  });
});
