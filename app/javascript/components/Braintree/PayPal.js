// @flow
import { Component } from 'react';
import paypal from 'braintree-web/paypal';
import type {
  PayPal as PayPalInstance,
  PayPalTokenizeOptions,
  PayPalTokenizePayload,
} from 'braintree-web/paypal';
import type { Client } from 'braintree-web';

type Props = {
  currency: string,
  amount?: number,
  client: Client,
  vault: boolean,
  onInit?: () => void,
  onFailure?: (data: any) => void,
};

type State = {
  paypalInstance: ?PayPalInstance,
  disabled: boolean,
};

export default class PayPal extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      paypalInstance: null,
      disabled: true,
    };
  }

  componentDidMount() {
    this.createPayPalInstance(this.props.client);
  }

  componentWillReceiveProps(newProps: Props) {
    if (newProps.client !== this.props.client) {
      this.createPayPalInstance(newProps.client);
    }
  }

  createPayPalInstance(client: any) {
    paypal.create({ client }, this.onPayPalCreate.bind(this));
  }

  onPayPalCreate(error: any, paypalInstance: any) {
    if (error) return;

    this.setState({ paypalInstance, disabled: false }, () => {
      if (this.props.onInit) {
        this.props.onInit();
      }
    });
  }

  componentWillUnmount() {
    if (this.state.paypalInstance) {
      this.state.paypalInstance.teardown();
    }
  }

  flow(): $PropertyType<PayPalTokenizeOptions, 'flow'> {
    if (this.props.vault) return 'vault';
    return 'checkout';
  }

  tokenizeOptions(): PayPalTokenizeOptions {
    const { amount, currency, vault } = this.props;
    if (vault) {
      return { flow: 'vault' };
    }
    return { flow: 'checkout', amount, currency };
  }

  submit(): Promise<any> {
    const paypalInstance = this.state.paypalInstance;
    return new Promise((resolve, reject) => {
      if (!paypalInstance) return reject();

      paypalInstance.tokenize(
        this.tokenizeOptions(),
        (error: ?BraintreeError, payload: PayPalTokenizePayload) => {
          if (error) return reject(error);
          resolve(payload);
        }
      );
    });
  }

  render() {
    return null;
  }
}
