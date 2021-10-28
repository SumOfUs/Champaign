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
      localPaymentTypes,
    } = this.props;

    const filteredPaymentTypes = paymentTypes.filter(paymentType => {
      switch (paymentType) {
        case 'paypal':
          return !(currency === 'ARS');
        case 'ideal':
          return localPaymentTypes.includes('ideal');
        case 'giropay':
          return localPaymentTypes.includes('giropay');
        default:
          return true;
      }
    });

    return (
      <div className="PaymentTypeSelection__payment-methods">
        <PaymentMethodWrapper>
          <span className="PaymentTypeSelection__prompt">
            <FormattedMessage
              id="fundraiser.payment_type_prompt"
              defaultMessage="Payment Method"
            />
          </span>

          {filteredPaymentTypes.map((paymentType, i) => {
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

const mapStateToProps = state => ({
  directDebitOnly: state.fundraiser.directDebitOnly,
  paymentTypes: state.fundraiser.paymentTypes,
  localPaymentTypes: state.fundraiser.localPaymentTypes,
  recurring: state.fundraiser.recurring,
  showDirectDebit: state.fundraiser.showDirectDebit,
  showIdeal: state.fundraiser.showIdeal,
  currentPaymentType: state.fundraiser.directDebitOnly
    ? 'gocardless'
    : state.fundraiser.currentPaymentType,
  currency: state.fundraiser.currency,
});

const mapDispatch = dispatch => ({});

export default connect(mapStateToProps, mapDispatch)(PaymentTypeSelection);
