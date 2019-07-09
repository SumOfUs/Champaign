import { Store } from 'redux';
import ComponentWrapper from '../../components/ComponentWrapper';
import { resetMember } from '../../state/member/reducer';
import { IAppState } from '../../types';
import { IFundraiserPluginConfig } from '../../window';
import Plugin from '../plugin';

interface IFundraiserOptions {
  el: HTMLElement;
  namespace: string;
  config: IFundraiserPluginConfig; // todo
  store: Store<IAppState>;
}

export function init(options: any) {
  if (!options.el) {
    throw new Error('Fundraiser plugin DOM element not found');
  }

  return new Fundraiser({
    el: options.el,
    namespace: 'petition',
    config: options.config,
    store: options.store,
  });
}

export class Fundraiser extends Plugin<IFundraiserPluginConfig> {
  public store: Store<IAppState>;

  constructor(options: IFundraiserOptions) {
    super(options);
    this.store = options.store;
    this.render();
  }

  public changeAmount(amount: number) {
    throw new Error('Not implemented');
  }

  public changeCurrency(currency: string) {
    throw new Error('Not implemented');
  }

  public updateForm(fieldName: string, value: any) {
    throw new Error('Not implemented');
  }

  // addPaymentMethod will allow us to add an object that contains:
  //   - label / name combo to show up in the list. Label can be HTML
  //   - a `setup` function, optional
  //   - a number of callbacks: onSubmit, onFailure, onSuccess
  public addPaymentMethod(paymentMethodData: any) {
    throw new Error('Not implemented');
  }

  public submitForm() {
    throw new Error('Not implemented');
  }

  public submitDonation() {
    throw new Error('Not implemented');
  }

  public render() {
    return null;
  }
}
