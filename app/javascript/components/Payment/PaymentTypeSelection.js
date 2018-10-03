// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import classnames from 'classnames';
import { without } from 'lodash';
import PaymentMethodWrapper from '../ExpressDonation/PaymentMethodWrapper';
import type { AppState } from '../../state';
import type { PaymentType } from '../../state/fundraiser/types';

type Props = {
  disabled?: boolean,
  currentPaymentType?: PaymentType,
  paymentTypes: PaymentType[],
  recurring: boolean,
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

  paymentTypes() {
    return this.props.paymentTypes;
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
            const currentDisabled =
              paymentType === 'google' && this.props.recurring;
            return (
              <div className={classnames('PaymentMethod', paymentType)} key={i}>
                <label>
                  <input
                    disabled={disabled || currentDisabled}
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
  recurring: state.fundraiser.recurring,
  recurringOnly: state.fundraiser.recurringDefault === 'only_recurring',
  showDirectDebit: state.fundraiser.showDirectDebit,
  directDebitOnly: state.fundraiser.directDebitOnly,
  paymentTypes: state.fundraiser.paymentTypes,
}))(PaymentTypeSelection);
