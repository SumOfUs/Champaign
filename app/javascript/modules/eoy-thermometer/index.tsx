import { connect } from 'react-redux';
import { Thermometer } from '../../components/Thermometer';
import DonationsThermometer from '../../plugins/donations_thermometer';
import { IAppState } from '../../types';

const ConnectedThermometer = connect((state: IAppState, ownProps) => ({
  ...ownProps,
  currency: state.fundraiser.currency,
}))(Thermometer);

export const init = options => {
  const element = document.getElementById('eoy-thermometer');
  if (!element) {
    return;
  }

  return new DonationsThermometer({
    // I have to pass both config and props. Config is specified in the plugin interface, and the logic for the
    // component itself requires either store or props.
    component: ConnectedThermometer,
    store: window.champaign.store,
    props: options,
    config: options,
    el: element,
  });
};
