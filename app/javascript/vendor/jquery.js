// @flow
import $ from 'jquery';

if (!window.$) window.$ = window.jQuery = $;

// jQuery plugins
require('jquery-ui');
require('jquery-ujs');
require('selectize');
require('jquery-sticky');

export default $;
