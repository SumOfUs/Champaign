import * as React from 'react';
import { render } from 'react-dom';
import { Store } from 'redux';
import ComponentWrapper from '../../components/ComponentWrapper';
import {
  changeAmount,
  changeCurrency,
  setPaymentType,
  setRecurring,
  setStoreInVault,
  updateForm,
} from '../../state/fundraiser/actions';
import { IAppState } from '../../types';
import { IFundraiserPluginConfig } from '../../window';
import Plugin from '../plugin';
import FundraiserView from './FundraiserView';
import { configureStore, fundraiserData } from './utils';

interface IFundraiserOptions {
  el: HTMLElement;
  namespace: string;
  config: IFundraiserPluginConfig; // todo
  store: Store<IAppState>;
}

export function init(options: any) {
  if (!options.el) {
    options.el = document.getElementById('fundraiser-component');
  }

  configureStore(fundraiserData(options.config), options.store.dispatch);

  return new Fundraiser({
    el: options.el,
    namespace: 'petition',
    config: options.config,
    store: options.store,
  });
}

export class Fundraiser extends Plugin<IFundraiserPluginConfig> {
  public store: Store<IAppState>;
  public customRenderer: (instance: Fundraiser) => any | undefined;

  constructor(options: IFundraiserOptions) {
    super(options);
    this.store = options.store;
    this.render();
  }

  get state() {
    return this.store.getState().fundraiser;
  }

  get formValues() {
    return this.state.form;
  }

  public changeAmount(amount: number) {
    this.store.dispatch(changeAmount(amount));
    return this;
  }

  public changeCurrency(currency: string) {
    this.store.dispatch(changeCurrency(currency));
    return this;
  }

  public updateForm(fieldName: string, value: any) {
    this.store.dispatch(
      updateForm({ ...this.formValues, ...{ [fieldName]: value } })
    );
    return this;
  }

  // addPaymentMethod will allow us to add an object that contains:
  //   - label / name combo to show up in the list. Label can be HTML
  //   - a `setup` function, optional
  //   - a number of callbacks: onSubmit, onFailure, onSuccess
  public addPaymentMethod(paymentMethodData: any) {
    throw new Error('Not implemented');
  }

  public validateForm() {
    this.events.emit('fundraiser:actions:validate_form');
    return this;
  }

  // TODO: Move the logic behind this event (check Payment.js)
  // to this class. The braintree client should also live here,
  // or perhaps in a braintree service, but not in the react component.
  // The <Payment/> react component has become quite complex and practically
  // unmaintainable
  public makePayment() {
    this.events.emit('fundraiser:actions:make_payment');
    return this;
  }

  public changeRecurring(value: boolean) {
    this.store.dispatch(setRecurring(value));
    return this;
  }

  public changeStoreInVault(value: boolean) {
    this.store.dispatch(setStoreInVault(value));
    return this;
  }

  // Sets the payment type (gocardless, paypal, card, etc). If the given payment
  // type is not supported, it will be set to the default payment type.
  public changePaymentType(paymentType: string) {
    this.store.dispatch(setPaymentType(paymentType));
    return this;
  }

  public render() {
    if (this.customRenderer) {
      return this.customRenderer(this);
    }

    return render(
      <ComponentWrapper store={this.store} locale={window.I18n.locale}>
        <FundraiserView />
      </ComponentWrapper>,
      this.el
    );
  }
}
