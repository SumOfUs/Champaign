import setupOnce from './setup_once';

$(function() {
  let ActionsEditor = Backbone.View.extend({
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
      let $target = $(e.target);
      let $publisher = $target.parents('.action-publisher');
      let current = $publisher.find('.btn-primary').data('state');
      let desired = $target.data('state');
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

  $.subscribe('actions:edit', function() {
    setupOnce('.actions-editor', ActionsEditor);
  });
});
