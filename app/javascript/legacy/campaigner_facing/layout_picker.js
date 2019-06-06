// @flow
import $ from 'jquery';
import Backbone from 'backbone';
import ee from '../../shared/pub_sub';
import setupOnce from './setup_once';

const LayoutPicker = Backbone.View.extend({
  events: {
    'click .radio-group__option': 'updateSelected',
    'change .layout-type-checkbox': 'showRelevantLayouts',
  },

  updateSelected(e) {
    let $target = $(e.target);
    if (!$target.hasClass('radio-group__option')) {
      // for bubbling
      $target = $target.parents('.radio-group__option');
    }
    const name = $target.find('.layout-settings__title').text();
    $target
      .parents('.layout-settings')
      .find('.layout-settings__current')
      .text(name);
    $target
      .parents('.layout-settings')
      .find('.radio-group__option')
      .removeClass('active');
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
    const $allRows = $target
      .closest('.form-group')
      .find('.radio-group__option');
    if ($target.is(':checked')) {
      $allRows.removeClass('hidden');
    } else {
      const layoutClass = this.getLayoutClass($target.attr('id'));
      $allRows.not(layoutClass).addClass('hidden');
    }
  },

  getLayoutClass(layout_select_id) {
    if (layout_select_id === 'primary') {
      return '.primary-layout';
    } else if (layout_select_id === 'follow-up') {
      return '.post-action-layout';
    }
  },
});

ee.on('pages:new', () => {
  setupOnce('.layout-settings', LayoutPicker);
});
ee.on('layout:edit', () => {
  setupOnce('.layout-settings', LayoutPicker);
});
