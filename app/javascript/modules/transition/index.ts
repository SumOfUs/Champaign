import * as $ from 'jquery';

export const transitionFromTo = (transition: string) => {
  const [tfrom, tto] = transition.split(':');
  const $from = document.querySelector(`[data-transition-id="${tfrom}"]`);
  const $to = document.querySelector(`[data-transition-id="${tto}"]`);

  if ($from && $to) {
    // TODO: without jQuery?
    $($from).fadeOut();
    $($to).fadeIn();

    $to.scrollIntoView({
      behavior: 'smooth',
      block: 'center',
      inline: 'nearest',
    });
  }
};
