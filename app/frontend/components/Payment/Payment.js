import React, { Component } from 'react';
import braintreeClient from 'braintree-web/client';
import PayPal from '../Braintree/PayPal';
import BraintreeCardFields from '../Braintree/BraintreeCardFields';

import { FormattedMessage } from 'react-intl';

import type { PayPalTokenizePayload } from 'braintree-web/paypal';

import './Payment.css';

export default class Payment extends Component {
  static title = <FormattedMessage id="payment" defaultMessage="payment" />;
  constructor(props) {
    super(props);
    this.state = {
      client: null,
    };
  }

  componentDidMount() {
    fetch('/api/payment/braintree/token')
      .then(response => response.json())
      .then(data => {
        braintreeClient.create({ authorization: data.token }, (err, instance) => {
          // todo: handle err?
          this.setState({ client: instance });
        });
      });
  }

  onPayPalSuccess(response: PayPalTokenizePayload) {
  }

  selectPaymentType(paymentType: string) {
    this.setState({ paymentType });
  }

  render() {
    return (
      <div className="Payment-root section">
        <div style={{backgroundColor: 'pink', padding: '10px', marginBottom: '10px'}}>
          User placeholder
        </div>

        <PayPal
          client={this.state.client}
          flow="checkout"
          onSuccess={this.onPayPalSuccess.bind(this)}
          onClick={() => this.selectPaymentType('paypal')}
          isActive={this.state.paymentType === 'paypal'}
        />

        <BraintreeCardFields
          client={this.state.client}
          onClick={() => this.selectPaymentType('card')}
          isActive={this.state.paymentType === 'card'}
        />

      </div>
    );
  }
}
