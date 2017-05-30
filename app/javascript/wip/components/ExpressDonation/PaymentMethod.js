// @flow
import React from 'react';
import { FormattedMessage } from 'react-intl';
import type { PaymentMethod } from '../../state';

type OwnProps = {
  paymentMethod: PaymentMethod;
  checked?: boolean;
  onChange?: (paymentMethod: PaymentMethod) => void;
};
export default ({ paymentMethod, checked, onChange }: OwnProps) => (
  <div id={`PaymentMethod-${paymentMethod.id}`} className="PaymentMethod">
    <label>
      { onChange &&
        <input
          type="radio"
          checked={checked}
          onChange={(e) => {
            if (e.target.checked && typeof onChange === 'function') {
              onChange(paymentMethod);
            }
          }}
        />
      }
      <FormattedMessage {...messageDescriptor(paymentMethod)} />
    </label>
  </div>
);

function messageDescriptor(paymentMethod: PaymentMethod) {
  const type = paymentMethod.instrument_type;
  if (type === 'credit_card') {
    return {
      id: 'fundraiser.oneclick.credit_card_payment_method',
      defaultMessage: '{card_type} ending in {last_four_digits}',
      values: {
        card_type: paymentMethod.card_type,
        last_four_digits: paymentMethod.last_4,
      },
    };
  }

  if (type === 'paypal_account') {
    return {
      id: 'fundraiser.oneclick.paypal_payment_method',
      defaultMessage: 'PayPal ({email})',
      values: { email: paymentMethod.email },
    };
  }

  return {
    id: 'fundraiser.oneclick.payment_method',
    defaultMessage: 'Payment method'
  };
}
