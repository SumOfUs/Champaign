import { isBoolean } from 'lodash';
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
import Plugin, { IPluginOptions } from '../plugin';
import FundraiserView from './FundraiserView';
import { configureStore, fundraiserData } from './utils';

export function init(options: any) {
  if (!options.el) {
    options.el = document.getElementById('fundraiser-component');
  }

  configureStore(fundraiserData(options.config), options.store.dispatch);

  return new Fundraiser({
    ...options,
    namespace: 'fundraiser',
  });
}

export class Fundraiser extends Plugin<IFundraiserPluginConfig> {
  public store: Store<IAppState>;
  public customRenderer: (instance: Fundraiser) => any | undefined;

  constructor(options: IPluginOptions<IFundraiserPluginConfig>) {
    super(options);
    this.render();
  }

  get state() {
    return this.store.getState().fundraiser;
  }

  get formValues() {
    return this.state.form;
  }

  get amount() {
    return this.state.donationAmount;
  }

  set amount(amount: any) {
    this.setAmount(amount);
  }

  public setAmount(amount: any) {
    if (Number.isInteger(amount) && amount > 0) {
      this.store.dispatch(changeAmount(amount));
    }
    return this;
  }

  get currency() {
    return this.state.currency;
  }

  set currency(currency: any) {
    this.setCurrency(currency);
  }

  public setCurrency(currency: any) {
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
    return new Promise((resolve, reject) => {
      this.events.once('fundraiser:form:success', resolve);
      this.events.once('fundraiser:form:error', reject);
      this.events.emit('fundraiser:actions:validate_form');
    });
  }

  // TODO: Move the logic behind this event (check Payment.js)
  // to this class. The braintree client should also live here,
  // or perhaps in a braintree service, but not in the react component.
  // The <Payment/> react component has become quite complex and practically
  // unmaintainable
  public makePayment(callback: (data: any, formData: any) => void) {
    return new Promise((resolve, reject) => {
      this.events.once('fundraiser:transaction_success', resolve);
      this.events.once('fundraiser:transaction_error', reject);
      this.events.emit('fundraiser:actions:make_payment');
    });
  }

  public configureHostedFields(config: any) {
    return new Promise((resolve, reject) => {
      this.events.once('fundraiser:configure:hosted_fields:success', resolve);
      this.events.once('fundraiser:configure:hosted_fields:error', reject);
      this.events.emit('fundraiser:configure:hosted_fields', config);
    });
  }

  get recurring() {
    return this.state.recurring;
  }

  set recurring(recurring: any) {
    this.setRecurring(recurring);
  }

  public setRecurring(value: any) {
    if (isBoolean(value)) {
      this.store.dispatch(setRecurring(value));
    }
    return this;
  }

  get storeInVault() {
    return this.state.storeInVault;
  }

  set storeInVault(value: any) {
    this.setStoreInVault(value);
  }

  public setStoreInVault(value: any) {
    if (isBoolean(value)) {
      this.store.dispatch(setStoreInVault(value));
    }
    return this;
  }

  // Sets the payment type (gocardless, paypal, card, etc). If the given payment
  // type is not supported, it will be set to the default payment type.
  public setPaymentType(paymentType: string) {
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
