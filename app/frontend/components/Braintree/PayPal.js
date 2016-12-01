// @flow
import React, { Component } from 'react';
import paypal from 'braintree-web/paypal';
import type { PayPalInstance, PayPalTokenizePayload } from 'braintree-web/paypal';

type OwnProps = {
  client: BraintreeClient;
  flow: 'checkout' | 'vault';
  onSuccess: (payload: PayPalTokenizePayload) => void;
  onClick?: () => void;
};

export default class PayPal extends Component {
  props: OwnProps;
  state: {
    paypalInstance: ?PayPalInstance;
    disabled: boolean;
  };

  constructor(props: OwnProps) {
    super(props);
    this.state = {
      paypalInstance: null,
      disabled: true,
    };
  }

  componentDidMount() {
    console.log('paypal component did mount');
    // create client instance
    const { client } = this.props;
    this.createPayPalInstance(client);
  }

  componentWillReceiveProps(newProps: OwnProps) {
    if (newProps.client) {
      paypal.create({ client: newProps.client }, this.onPayPalCreate.bind(this));
    }
  }

  createPayPalInstance(client: any) {
    paypal.create({ client }, this.onPayPalCreate.bind(this));
  }

  onPayPalCreate(error: any, paypalInstance: any) {
    if (error) return;

    console.log('paypal created, setting disabled to false');
    this.setState({ paypalInstance, disabled: false });
  }

  onClick() {
    const paypalInstance = this.state.paypalInstance;

    if (!paypalInstance) return;

    paypalInstance.tokenize({
      flow: this.props.flow,
    }, this.tokenizeCallback.bind(this));
  }

  tokenizeCallback(error: ?BraintreeError, payload: PayPalTokenizePayload) {
    if (error) {
      console.log('error during tokenize', error);
      return;
    }

    console.log('tokenize payload:', payload);
    this.props.onSuccess(payload);
  }

  render() {
    return (
      <div className="BraintreePayPal-root" onClick={this.props.onClick}>
        <button
          className="BraintreePayPal-button"
          disabled={this.state.disabled}
          onClick={this.onClick.bind(this)}>
          <input type="radio" name="paypal-radio"/>
          <label htmlFor="paypal-radio">PayPal</label>
        </button>
      </div>
    );
  }
}
