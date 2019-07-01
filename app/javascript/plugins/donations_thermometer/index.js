// @flow
import React from 'react';
import { render } from 'react-dom';
import {
  default as ConnectedThermometer,
  Thermometer,
} from '../../components/Thermometer';
import ComponentWrapper from '../../components/ComponentWrapper';
import { update } from '../../state/thermometer';

import type { Props } from '../../components/Thermometer';
import type { Store } from 'redux';
import type { AppState } from '../../state';
import type { State } from '../../state/thermometer';

type Config = {
  el: HTMLElement,
  props?: Props,
  store?: Store<AppState, *>,
};

export default class DonationsThermometer {
  el: HTMLElement;
  store: Store<AppState, *>;
  props: Props;
  instance: any;

  constructor(config: Config) {
    if (!config.el) {
      throw new Error(
        'Donations Thermometer must be initialised with an element and a store.'
      );
    }

    if (!config.store && !config.props) {
      throw new Error(
        'Donations Thermometer must be initialised with either a redux store, or props'
      );
    }

    this.el = config.el;
    if (config.props) this.props = config.props;
    if (config.store) this.store = config.store;

    this.instance = this.render();
  }

  get state() {
    if (!this.store) return null;
    return this.store.getState().donationsThermometer;
  }

  set state(attrs: State) {
    if (!this.store)
      throw new Error(
        `Can't set state on this thermometer. Check that you initialised it with a (redux) store`
      );
    this.store.dispatch(update(attrs));
  }

  /**
   * Updates the thermometer's props when not connected to a store.
   * @param  {Props} props
   */
  updateProps(props: Props) {
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
  updateStore(attrs: State) {
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

  renderWithProps() {
    return render(
      <ComponentWrapper store={this.store} locale={window.I18n.locale}>
        <Thermometer {...this.props} />
      </ComponentWrapper>,
      this.el
    );
  }

  renderWithStore() {
    return render(
      <ComponentWrapper store={this.store} locale={window.I18n.locale}>
        <ConnectedThermometer />
      </ComponentWrapper>,
      this.el
    );
  }

  // Renders a component with props or with the redux store.
  // Props will always take precedence if present.
  render() {
    if (this.props) return this.renderWithProps();
    if (this.store) return this.renderWithStore();
  }
}

export function init() {
  console.log('donations_thermometer initializing...');
}
