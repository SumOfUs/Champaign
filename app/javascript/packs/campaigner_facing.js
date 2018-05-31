// Copied over from previous file in
// assets/javascripts/application.js manifest
// A lot of this might be unnecessary (and it will do well
// to reduce bundle size)

// TODO: Refactor this to *not* get imported into the global scope
require('d3');
import '../shared/pub_sub';
import '../shared/show_errors';
import '../campaigner_facing/syntax_highlighting';
import '../campaigner_facing/dropzone_image_upload';
import '../campaigner_facing/selectize_config';
import '../campaigner_facing/search';
import '../campaigner_facing/configure_wysiwyg';
import '../campaigner_facing/form_preview';
import '../campaigner_facing/ajax';
import '../campaigner_facing/page';
import '../campaigner_facing/plugins_toggle';
import '../campaigner_facing/sidebar';
import '../campaigner_facing/tooltips';
import '../campaigner_facing/collection_editor';
import '../campaigner_facing/shares_editor';
import '../campaigner_facing/actions_editor';
import '../campaigner_facing/layout_picker';

import PageEditBar from '../campaigner_facing/page_edit_bar';
import Analytics from '../campaigner_facing/analytics';
import SurveyEditor from '../campaigner_facing/survey_editor';
import FormElementCreator from '../campaigner_facing/form_element_creator';
import ListEditor from '../campaigner_facing/list_editor';
import Twitter from 'twitter-text';

// Styles
import 'c3/c3.css';

require('backbone');
require('lodash');

Object.assign(window, {
  PageEditBar,
  Analytics,
  SurveyEditor,
  FormElementCreator,
  ListEditor,
  Twitter,
});
