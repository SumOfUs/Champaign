import * as React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../../components/ComponentWrapper';
import {
  default as ConnectedThermometer,
  Thermometer,
} from '../../components/Thermometer';
import { update } from '../../state/thermometer';
import { IDonationsThermometerPluginConfig } from '../../window';
import Plugin, { IPluginOptions } from '../plugin';

interface IDonationsThermometerOptions
  extends IPluginOptions<IDonationsThermometerPluginConfig> {
  props?: any;
}

export default class DonationsThermometer extends Plugin<
  IDonationsThermometerPluginConfig
> {
  public props?: any;
  public customRenderer: (instance: DonationsThermometer) => any;

  constructor(options: IDonationsThermometerOptions) {
    super(options);
    if (!options.el) {
      throw new Error(
        'Donations Thermometer must be initialised with an element and a store.'
      );
    }

    if (!options.store && !options.props) {
      throw new Error(
        'Donations Thermometer must be initialised with either a redux store, or props'
      );
    }

    this.el = options.el;
    if (options.props) {
      this.props = options.props;
    }
    if (options.store) {
      this.store = options.store;
    }

    this.render();
  }

  get state() {
    if (!this.store) {
      return null;
    }
    return this.store.getState().donationsThermometer;
  }

  set state(attrs) {
    if (!this.store) {
      throw new Error(
        `Can't set state on this thermometer. Check that you initialised it with a (redux) store`
      );
    }
    this.store.dispatch(update(attrs));
  }

  /**
   * Updates the thermometer's props when not connected to a store.
   * @param  {Props} props
   */
  public updateProps(props) {
    if (!this.props) {
      throw new Error(
        `Can't set props on this thermometer. Check that you correctly initialised it with props.`
      );
    }

    if (!props) {
      throw new Error(`Can't set props to null or undefined.`);
    }

    this.props = { ...this.props, ...props };
    this.render();
  }

  /**
   * Updates the redux store state associated with the donations thermometer.
   * @param {State} attrs
   */
  public updateStore(attrs) {
    if (!this.store) {
      throw new Error(
        `Can't update the store on this thermometer. Check that you initialised it with a (redux) store`
      );
    }

    if (!attrs) {
      throw new Error(`Can't update the store with null or undefined.`);
    }

    this.store.dispatch(update(attrs));
  }

  public renderWithProps() {
    return render(
      <ComponentWrapper store={this.store} locale={window.I18n.locale}>
        <Thermometer {...this.props} />
      </ComponentWrapper>,
      this.el
    );
  }

  public renderWithStore() {
    return render(
      <ComponentWrapper store={this.store} locale={window.I18n.locale}>
        <ConnectedThermometer />
      </ComponentWrapper>,
      this.el
    );
  }

  // Renders a component with props or with the redux store.
  // Props will always take precedence if present.
  public render() {
    if (this.props) {
      return this.renderWithProps();
    }
    if (this.store) {
      return this.renderWithStore();
    }
  }
}

export const init = options => {
  options.el =
    options.el ||
    document.getElementById(`chmp-inline-thermometer__${options.config.ref}`);

  if (!options.el) {
    return;
  }

  return new DonationsThermometer({
    config: options.config,
    customRenderer: options.customRenderer,
    el: options.el,
    eventEmitter: options.eventEmitter,
    namespace: 'donationsthermometer',
    store: options.store,
  });
};
