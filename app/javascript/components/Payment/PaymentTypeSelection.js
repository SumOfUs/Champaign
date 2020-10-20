import React, { PureComponent } from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import classnames from 'classnames';
import { without } from 'lodash';
import PaymentMethodWrapper from '../ExpressDonation/PaymentMethodWrapper';

export class PaymentTypeSelection extends PureComponent {
  showCardAndPaypal() {
    if (this.props.directDebitOnly && !this.props.showDirectDebit) return true;
    if (this.props.directDebitOnly) return false;
    return true;
  }

  render() {
    const {
      disabled,
      currentPaymentType,
      onChange,
      currency,
      paymentTypes,
    } = this.props;

    return (
      <div className="PaymentTypeSelection__payment-methods">
        <PaymentMethodWrapper>
          <span className="PaymentTypeSelection__prompt">
            <FormattedMessage
              id="fundraiser.payment_type_prompt"
              defaultMessage="Payment Method"
            />
          </span>

          {paymentTypes.map((paymentType, i) => {
            // this is done since PAYPAL doesnt support ARS currency as of now
            if (currency === 'ARS' && paymentType === 'paypal' ? false : true) {
              return (
                <div
                  className={classnames('PaymentMethod', paymentType)}
                  key={i}
                >
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
            }
          })}
        </PaymentMethodWrapper>
      </div>
    );
  }
}

const mapStateToProps = state => ({
  directDebitOnly: state.fundraiser.directDebitOnly,
  paymentTypes: state.fundraiser.paymentTypes,
  recurring: state.fundraiser.recurring,
  showDirectDebit: state.fundraiser.showDirectDebit,
  currentPaymentType: state.fundraiser.directDebitOnly
    ? 'gocardless'
    : state.fundraiser.currentPaymentType,
  currency: state.fundraiser.currency,
});

const mapDispatch = dispatch => ({});

export default connect(mapStateToProps, mapDispatch)(PaymentTypeSelection);
