// @flow
import $ from 'jquery';
import ee from '../shared/pub_sub';

export default class ProgressTracker {
  constructor() {
    this.addEventListeners();
  }

  addEventListeners() {
    ee.on('action:submitted_success', this.show);
    ee.on('action:submitted_success', () => this.tick('signed'));
    ee.on('fundraiser:transaction_success', () => this.tick('donated'));
    window.addEventListener('share', () => this.tick('shared'), false);
    $('.two-step__decline').on('click', () => {
      this.cross('shared');
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

  tick(section: string) {
    $(`.progress-tracker__circle--${section}`)
      .removeClass('progress-tracker__circle--cross')
      .addClass('progress-tracker__circle--tick');
  }

  cross(section: string) {
    $(`.progress-tracker__circle--${section}`)
      .removeClass('progress-tracker__circle--tick')
      .addClass('progress-tracker__circle--cross');
  }
}
