import * as $ from 'jquery';

function makeTransition(transition) {
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
    $($from).fadeOut();
  }
}

export const transitionFromTo = (transitionString: string) => {
  if (transitionString.includes('__')) {
    const transitions = transitionString.split('__');
    transitions.map(transition => makeTransition(transition));
  } else {
    makeTransition(transitionString);
  }
};
