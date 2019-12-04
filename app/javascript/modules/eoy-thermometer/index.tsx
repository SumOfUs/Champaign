import { Thermometer } from '../../components/Thermometer';
import DonationsThermometer from '../../plugins/donations_thermometer';

export const init = options => {
  const element = document.getElementById('eoy-thermometer');
  if (!element) {
    return;
  }

  return new DonationsThermometer({
    // I have to pass both config and props. Config is specified in the plugin interface, and the logic for the
    // component itself requires either store or props.
    // component: Thermometer,
    config: options,
    props: options,
    el: element,
  });
};
