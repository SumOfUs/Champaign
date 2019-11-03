import ee from '../../shared/pub_sub';

const TALL_EDITORS = ['page_body'];

function configureWysiwyg(id, editorOptions = []) {
  const $editor = $('#' + id);
  if ($editor.length === 0) {
    return;
  }

  $editor.summernote({
    toolbar: editorOptions.length
      ? editorOptions
      : [
          ['style', ['bold', 'italic', 'underline', 'clear']],
          ['font', ['fontsize']],
          ['para', ['ul', 'ol', 'paragraph']],
          ['color', ['color']],
          ['insert', ['link', 'picture', 'video']],
          ['view', ['fullscreen', 'codeview', 'help']],
        ],
    height: TALL_EDITORS.indexOf(id) > -1 ? 280 : 120,
    fontSizes: ['8', '10', '11', '12', '14', '16', '20', '24', '36', '72'],
    codemirror: {
      theme: 'default',
      mode: 'text/html',
      lineNumbers: true,
      tabMode: 'indent',
      lineWrapping: true,
    },
  });
  const $contentField = $('#' + id + '_content');

  $editor.summernote('fontSize', '16'); // default

  $editor.summernote('code', $contentField.val());

  // In order to make an iframe size down with the containing column
  // or to fit on screen on mobile, you have to apply style to the iframe
  // and to the containing element. This adds a class to the containing element
  // that our CSS is looking for.
  const encapsulateIframes = function(html) {
    if (html.indexOf('iframe') === -1) {
      return html; // don't do anything if there's no iframe
    }
    const $html = $(html);
    // addClass is idempotent so we just call it every time we save
    $html
      .find('iframe')
      .parent()
      .addClass('iframe-responsive-container');
    // this little goof is just cause jquery doesn't have $el.outerHtml();
    return $('<div></div>')
      .append($html)
      .html();
  };

  const updateContentBeforeSave = function() {
    const content = encapsulateIframes($editor.summernote('code'));
    $contentField.val(content);
  };

  ee.on('wysiwyg:submit', updateContentBeforeSave);
}

ee.on('wysiwyg:setup', configureWysiwyg);
