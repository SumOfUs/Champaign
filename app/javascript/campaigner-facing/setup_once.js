const setupOnce = function(selector, viewClass) {
  $(selector).each(function(ii, el){
    let $el = $(el);
    if( $el.data('js-inited') != true) {
      let toggle = new viewClass({ el: $el });
      $el.data('js-inited', true)
    }
  });
}

module.exports = setupOnce;
