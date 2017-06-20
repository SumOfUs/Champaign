import $ from 'jquery';

const configureDropZone = function() {
  Dropzone.options.dropzone = {
    maxFilesize: 2,
    paramName: 'image[content]',
    addRemoveLinks: false,
    previewsContainer: null,
    createImageThumbnails: true,
    previewTemplate: document.querySelector('#dropzone-preview-template')
      .innerHTML,

    init: function() {
      this.on('success', function(resp, html) {
        $('.campaign-images .notice').hide();
        $('.dz-success').replaceWith(html);
        const id = $(html).data('image-id');
        $.publish('image:success', [resp, id, html]);
      });

      this.on('addedfiled', function(file) {
        this.removeFile(file);
      });
    },
  };
};

const bindHandlers = function() {
  $('.campaign-images').on('ajax:success', 'a[data-method=delete]', function() {
    $(this).parents('.dz-preview').fadeOut();
    const imageId = $(this).parents('[data-image-id]').data('image-id');
    $.publish('image:destroyed', imageId);
  });
};

const initialize = function() {
  console.log('hi');
  configureDropZone();
  bindHandlers();
};

const addImageOption = function(e, file, id, html) {
  const newOption = "<option value='" + id + "'>" + file.name + '</option>';
  $('#page_primary_image_id').append(newOption);
};

const removeImageOption = function(e, id) {
  $('#page_primary_image_id').find('option[value="' + id + '"]').remove();
};

$.subscribe('dropzone:setup', initialize);
$.subscribe('image:success', addImageOption);
$.subscribe('image:destroyed', removeImageOption);
