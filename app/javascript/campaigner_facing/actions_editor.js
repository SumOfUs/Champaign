import ee from '../shared/pub_sub';
import setupOnce from './setup_once';

const ActionsEditor = Backbone.View.extend({
  events: {
    'click .action-publisher .btn': 'handleClick',
    'ajax:success form.shares-editor__new-form': 'clearFormAndConformView',
  },

  initialize() {
    this.pageId = this.$el.data('page-id');
  },

  updateButtons($publisher, desired) {
    $publisher.find('.btn-primary').removeClass('btn-primary');
    $publisher.find('[data-state="' + desired + '"]').addClass('btn-primary');
  },

  handleClick(e) {
    const $target = $(e.target);
    const $publisher = $target.parents('.action-publisher');
    const current = $publisher.find('.btn-primary').data('state');
    const desired = $target.data('state');
    this.updateAction($publisher, desired, current);
  },

  updateAction($publisher, desired, last) {
    this.updateButtons($publisher, desired);
    $.ajax(`/api/pages/${this.pageId}/actions/${$publisher.data('id')}`, {
      method: 'PUT',
      data: { publish_status: desired },
    }).fail(() => {
      this.updateButtons($publisher, last);
    });
  },
});

ee.on('actions:edit', function() {
  setupOnce('.actions-editor', ActionsEditor);
});
