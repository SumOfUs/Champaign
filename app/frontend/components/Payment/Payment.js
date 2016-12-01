import React, { Component } from 'react';
import braintreeClient from 'braintree-web/client';
import PayPal from '../Braintree/PayPal';
import BraintreeCardFields from '../Braintree/BraintreeCardFields';

import { FormattedMessage } from 'react-intl';

import type { PayPalTokenizePayload } from 'braintree-web/paypal';

import './Payment.css';

export default class Payment extends Component {
  static title = <FormattedMessage id="payment" defaultMessage="payment" />;
  paypal: PayPal;
  cardFields: BraintreeCardFields;

  constructor(props) {
    super(props);
    this.state = {
      client: null,
      loading: true,
      paymentType: null,
    };
  }

  componentDidMount() {
    fetch('/api/payment/braintree/token')
      .then(response => response.json())
      .then(data => {
        braintreeClient.create({ authorization: data.token }, (err, instance) => {
          // todo: handle err?
          this.setState({ client: instance, loading: false });
        });
      });
  }

  onPayPalSuccess(response: PayPalTokenizePayload) {
  }

  selectPaymentType(paymentType: string) {
    this.setState({ paymentType });
  }

  render() {
    if (this.refs.cardFields) console.log('card fields:', this.refs.cardFields);
    return (
      <div className="Payment section">
        <div style={{backgroundColor: 'pink', padding: '10px', marginBottom: '10px'}}>
          User placeholder
        </div>
        // STORED PAYMENT METHODS

        <div className="Payment__options">
          <label className="Payment__option">
            <input
              type="radio"
              name="paymentOption"
              value="gocardless"
              onChange={(e) => this.selectPaymentType(e.currentTarget.value)} />
            Go Cardless
          </label>

          <label className="Payment__option">
            <input
              type="radio"
              name="paymentOption"
              value="paypal"
              onChange={(e) => this.selectPaymentType(e.currentTarget.value)} />
            PayPal
          </label>

          <label className="Payment__option">
            <input
              type="radio"
              name="paymentOption"
              value="card"
              onChange={(e) => this.selectPaymentType(e.currentTarget.value)} />
            Credit or Debit Card
          </label>
        </div>

        <BraintreeCardFields
          ref="btCardFields"
          client={this.state.client}
          onClick={() => this.selectPaymentType('card')}
          isActive={this.state.paymentType === 'card'}
        />

        <hr />

        <input type="checkbox" name="recurring" />

        <input type="checkbox" name="recurring" />

      </div>
    );
  }
}
