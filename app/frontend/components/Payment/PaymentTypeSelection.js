// @flow
import React, { Component } from 'react';
import PaymentTypePill from './PaymentTypePill';
import { FormattedMessage } from 'react-intl';

export default class PaymentTypeSelection extends Component {
  props: {
    disabled?: boolean;
    currentPaymentType?: string;
    onChange: (paymentType: string) => void;
  };

  render() {
    const { disabled, currentPaymentType, onChange } = this.props;

    return (
      <div className="PaymentTypeSelection Payment__options">
        <PaymentTypePill
          name="gocardless"
          disabled={disabled}
          checked={currentPaymentType === 'gocardless'}
          onChange={() => onChange('gocardless')}>
          <FormattedMessage
            id="fundraiser.debit.direct_debit"
            defaultMessage="Direct Debit" />
        </PaymentTypePill>

        <PaymentTypePill
          name="paypal"
          disabled={disabled}
          checked={currentPaymentType === 'paypal'}
          onChange={() => onChange('paypal')}>
          PayPal
        </PaymentTypePill>

        <PaymentTypePill
          name="card"
          disabled={disabled}
          checked={currentPaymentType === 'card'}
          activeColor="#00c0cf"
          onChange={() => onChange('card')}>
          <FormattedMessage
            id="fundraiser.pay_by_card"
            defaultMessage="Credit or Debit Card" />
        </PaymentTypePill>
      </div>
    );
  }
}
