// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import PaymentMethodWrapper from '../ExpressDonation/PaymentMethodWrapper';

export default class PaymentTypeSelection extends Component {
  props: {
    disabled?: boolean;
    currentPaymentType?: string;
    onChange: (paymentType: string) => void;
    showDirectDebit: ?boolean;
  };

  render() {
    const { disabled, currentPaymentType, onChange } = this.props;
    const methods = ['card', 'paypal'];
    if (this.props.showDirectDebit) methods.push('gocardless');

    return (
      <div className='ExpressDonation__payment-methods'>
        <PaymentMethodWrapper>
          <span className="ExpressDonation__prompt">
            <FormattedMessage id="fundraiser.payment_type_prompt" />
          </span>

          {methods.map((method) => {
            return (<div className="PaymentMethod">
              <label>
                  <input
                    disabled={disabled}
                    type="radio"
                    checked={currentPaymentType === method}
                    onChange={(e) => onChange(method)}
                  />
                <FormattedMessage id={`fundraiser.payment_methods.${method}`} />
              </label>
              { currentPaymentType === method && currentPaymentType !== 'card' &&
                <div className="PaymentMethod__guidance">
                  <FormattedMessage id={`fundraiser.payment_methods.ready_for_${method}`} />
                </div>
              }
            </div>);
          })}
        </PaymentMethodWrapper>
      </div>
    );
  }
}
