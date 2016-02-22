const setupOnce = require('setup_once');

(function(){

  let LayoutPicker = Backbone.View.extend({

    events: {
      'click .radio-group__option': 'updateSelected',
      'change .layout-type-checkbox': 'showRelevantLayouts'
    },

    updateSelected(e) {
      let $target = $(e.target);
      if (!$target.hasClass('radio-group__option')) {
        // for bubbling
        $target = $target.parents('.radio-group__option')
      }
      const name = $target.find('.layout-settings__title').text();
      $target.parents('.layout-settings').find('.layout-settings__current').text(name);
      $target.parents('.layout-settings').find('.radio-group__option').removeClass('active');
      $target.addClass('active');
      this.updatePlan($target);
    },

    updatePlan($target) {
      const $input = $target.find(`#${$target.attr('for')}`);
      if ($input.attr('name') === 'page[follow_up_liquid_layout_id]') {
        this.$('#page_follow_up_plan_with_liquid').prop('checked', true);
      }
    },

    showRelevantLayouts(e) {
      const $target = $(e.target);
      const layoutClasses = this.getLayoutClasses($target.attr('id'));
      const layoutRows = $target.closest('.form-group').find(layoutClasses.inverse_class).not(layoutClasses.own_class);
      if ($target.is(':checked')) {
        layoutRows.removeClass('hidden');
      } else {
        layoutRows.addClass('hidden');
      }
    },

    getLayoutClasses(layout_select_id) {
      if (layout_select_id==='primary') {
        return {inverse_class: '.post-action-layout', own_class: '.primary-layout'}
      } else if (layout_select_id==='follow-up') {
        return {inverse_class: '.primary-layout', own_class: '.post-action-layout'}
      }
    }

  });

  $.subscribe("layout:edit pages:new", function(){
    setupOnce('.layout-settings', LayoutPicker);
  });
}());
