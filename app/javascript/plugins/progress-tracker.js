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
    window.addEventListener(
      'share',
      () => this.addEventListeners.tick('shared'),
      false
    );
    $('.two-step__decline').on('click', () => {
      this.cross('shared');
    });
  }

  show() {
    const $tracker = $('.header-logo .progress-tracker');
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
    console.log('cross:', section);
    $(`.progress-tracker__circle--${section}`)
      .removeClass('progress-tracker__circle--tick')
      .addClass('progress-tracker__circle--cross');
  }

  setup() {
    ee.on('action:submitted_success', function() {});
  }
}
/*
window.ee.on('action:submitted_success', function() {
  $('.header-logo__left-constraint').append($(progressTracker));
  $('.Stepper.fundraiser-bar__top').prepend(
    $(progressTracker).addClass('progress-tracker--fundraiser')
  );
  $('.progress-tracker__circle--signed').addClass(
    'progress-tracker__circle--tick'
  );
});

window.addEventListener(
  'share',
  function() {
    $('.progress-tracker__circle--shared')
      .removeClass('progress-tracker__circle--cross')
      .addClass('progress-tracker__circle--tick');
    ga('send', 'event', 'fa-progress-tracker', 'share', 'variant');
    faa.event('fa-progress-tracker', 'share', 'variant');
  },
  false
);

$('.two-step__decline').on('click', function() {
  $('.progress-tracker__circle--shared')
    .removeClass('progress-tracker__circle--tick')
    .addClass('progress-tracker__circle--cross');
});

*/
