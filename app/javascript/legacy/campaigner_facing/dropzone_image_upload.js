import $ from 'jquery';
import ee from '../../shared/pub_sub';

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
        ee.emit('image:success', resp, id, html);
      });

      this.on('addedfiled', function(file) {
        this.removeFile(file);
      });
    },
  };
};

const bindHandlers = function() {
  $('.campaign-images').on('ajax:success', 'a[data-method=delete]', function() {
    $(this)
      .parents('.dz-preview')
      .fadeOut();
    const imageId = $(this)
      .parents('[data-image-id]')
      .data('image-id');
    ee.emit('image:destroyed', imageId);
  });
};

const initialize = function() {
  configureDropZone();
  bindHandlers();
};

const addImageOption = function(file, id, html) {
  const newOption = "<option value='" + id + "'>" + file.name + '</option>';
  $('#page_primary_image_id').append(newOption);
};

const removeImageOption = function(id) {
  $('#page_primary_image_id')
    .find('option[value="' + id + '"]')
    .remove();
};

ee.on('dropzone:setup', initialize);
ee.on('image:success', addImageOption);
ee.on('image:destroyed', removeImageOption);
