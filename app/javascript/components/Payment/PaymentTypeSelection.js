// @flow
import React, { PureComponent } from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import classnames from 'classnames';
import { without } from 'lodash';
import PaymentMethodWrapper from '../ExpressDonation/PaymentMethodWrapper';
import type { AppState } from '../../state';
import type { PaymentType } from '../../state/fundraiser/types';
import type { Dispatch } from 'redux';

type Props = {
  currentPaymentType?: PaymentType,
  directDebitOnly: boolean,
  disabled?: boolean,
  features: $PropertyType<AppState, 'features'>,
  onChange: (paymentType: PaymentType) => void,
  paymentTypes: PaymentType[],
  recurring: boolean,
  showDirectDebit: boolean,
};
export class PaymentTypeSelection extends PureComponent<Props> {
  showCardAndPaypal() {
    if (this.props.directDebitOnly && !this.props.showDirectDebit) return true;
    if (this.props.directDebitOnly) return false;
    return true;
  }

  paymentTypes(): PaymentType[] {
    if (!this.props.features.googlepay) {
      return without(this.props.paymentTypes, 'google');
    }

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

const mapStateToProps = (state: AppState) => ({
  directDebitOnly: state.fundraiser.directDebitOnly,
  features: state.features,
  paymentTypes: state.fundraiser.paymentTypes,
  recurring: state.fundraiser.recurring,
  showDirectDebit: state.fundraiser.showDirectDebit,
  currentPaymentType: state.fundraiser.directDebitOnly
    ? 'gocardless'
    : state.fundraiser.currentPaymentType,
});

const mapDispatch = (dispatch: Dispatch<*>) => ({});

export default connect(
  mapStateToProps,
  mapDispatch
)(PaymentTypeSelection);
