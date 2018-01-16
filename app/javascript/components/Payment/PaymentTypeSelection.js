// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import classnames from 'classnames';
import PaymentMethodWrapper from '../ExpressDonation/PaymentMethodWrapper';
import type { AppState } from '../../state';
import type { PaymentType } from '../../state/fundraiser/types';

type Props = {
  disabled?: boolean,
  currentPaymentType?: string,
  onChange: (paymentType: string) => void,
  showDirectDebit: boolean,
  directDebitOnly: boolean,
};
export class PaymentTypeSelection extends Component {
  props: Props;

  showCardAndPaypal() {
    if (this.props.directDebitOnly && !this.props.showDirectDebit) return true;
    if (this.props.directDebitOnly) return false;
    return true;
  }

  paymentTypes(): PaymentType[] {
    const paymentTypes = [];

    if (this.props.showDirectDebit) {
      paymentTypes.push('gocardless');
    }

    if (this.showCardAndPaypal()) {
      paymentTypes.push('paypal', 'card');
    }

    return paymentTypes;
  }

  render() {
    const { disabled, currentPaymentType, onChange } = this.props;

    return (
      <div className="PaymentTypeSelection__payment-methods">
        <PaymentMethodWrapper>
          <span className="PaymentTypeSelection__prompt">
            <FormattedMessage
              id="fundraiser.payment_type_prompt"
              defaultMessage="Payment Method"
            />
          </span>

          {this.paymentTypes().map((paymentType, i) => {
            return (
              <div className={classnames('PaymentMethod', paymentType)} key={i}>
                <label>
                  <input
                    disabled={disabled}
                    type="radio"
                    checked={currentPaymentType === paymentType}
                    onChange={e => onChange(paymentType)}
                  />
                  <FormattedMessage
                    id={`fundraiser.payment_methods.${paymentType}`}
                    defaultMessage="Unknown payment method"
                  />
                </label>
              </div>
            );
          })}
        </PaymentMethodWrapper>
      </div>
    );
  }
}

export default connect((state: AppState) => ({
  showDirectDebit: state.fundraiser.showDirectDebit,
  directDebitOnly: state.fundraiser.directDebitOnly,
}))(PaymentTypeSelection);
