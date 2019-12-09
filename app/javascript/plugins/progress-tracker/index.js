import $ from 'jquery';
import ee from '../../shared/pub_sub';

export default class ProgressTracker {
  constructor() {
    this.addEventListeners();
  }

  addEventListeners() {
    const $header = $('.header-logo');
    ee.on('action:submitted_success', this.show);
    ee.on('action:submitted_success', () => this.tick('signed'));
    ee.on('fundraiser:transaction_success', () => this.tick('donated'));
    window.addEventListener(
      'share',
      () => {
        if ($('.overlay-visible').length > 0) {
          $header.hide();
        }
        this.tick('shared');
      },
      false
    );
    ee.on('two_step:decline', () => {
      if ($('.overlay-visible').length > 0) {
        $header.hide();
      }
      $('[data-step="two"]')
        .removeClass('progress-tracker__circle--tick')
        .addClass('progress-tracker__circle--cross');
    });
  }

  show() {
    const $header = $('.header-logo');
    const $tracker = $('.header-logo .progress-tracker');

    $header.addClass('with-progress-tracker');

    $tracker
      .removeClass('hidden-closed')
      .clone()
      .addClass('progress-tracker--fundraiser')
      .prependTo('.Stepper.fundraiser-bar__top');
  }

  tick(section) {
    $(`.progress-tracker__circle--${section}`)
      .removeClass('progress-tracker__circle--cross')
      .addClass('progress-tracker__circle--tick');
  }

  cross(section) {
    $(`.progress-tracker__circle--${section}`)
      .removeClass('progress-tracker__circle--tick')
      .addClass('progress-tracker__circle--cross');
  }
}
