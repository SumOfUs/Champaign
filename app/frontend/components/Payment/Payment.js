import React, { Component } from 'react';
import { FormattedMessage, FormattedNumber } from 'react-intl';
import { connect } from 'react-redux';
import PayPal from '../Braintree/PayPal';
import BraintreeCardFields from '../Braintree/BraintreeCardFields';
import PaymentTypePill from './PaymentTypePill';
import Button from '../Button/Button';
import WelcomeMember from '../WelcomeMember/WelcomeMember';
import braintreeClient from 'braintree-web/client';
import dataCollector from 'braintree-web/data-collector';
import { resetMember } from '../../state/member/actions';
import {
  changeStep,
  setRecurring,
  setStoreInVault,
  setPaymentType,
} from '../../state/fundraiser/actions';

import './Payment.css';

const FORMATTED_NUMBER_DEFAULTS = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

type OwnProps = {
  currency: string;
  donationAmount: ?number;
  member: MemberState;
  recurring: boolean;
  disableRecurring: boolean;
  storeInVault: boolean;
  changeStep: () => void;
  setRecurring: () => void;
  setStoreInVault: () => void;
};
export class Payment extends Component {
  props: OwnProps;
  static title = <FormattedMessage id="payment" defaultMessage="payment" />;
  paypal: PayPal;
  cardFields: BraintreeCardFields;

  constructor(props) {
    super(props);
    this.state = {
      client: null,
      deviceData: {},
      loading: true,
      submitting: false,
      initializing: {
        gocardless: true,
        paypal: true,
        card: true,
      },
    };

    this.callbacks = {};
  }

  componentDidMount() {
    // TODO: move to a service layer that returns a Promise
    $.get('/api/payment/braintree/token')
      .then(data => {
        braintreeClient.create({ authorization: data.token }, (error, client) => {
          // todo: handle err?
          dataCollector.create({
            client,
            kount: true,
            paypal: true,
          }, (err, collectorInst) => {
            if (err) { return this.setState({ client, loading: false }); }

            const deviceData = collectorInst.deviceData;
            this.setState({
              client,
              deviceData: JSON.parse(deviceData),
              loading: false
            });
          });
        });
      });
  }

  selectPaymentType(paymentType: string) {
    this.props.setPaymentType(paymentType);
  }

  resetMember() {
    this.props.resetMember();
  }

  paymentInitialized(name: string) {
    this.setState({ initializing: { ...this.state.initializing, [name]: false } });
  }

  loading() {
    return this.state.loading || this.state.initializing[this.props.fundraiser.currentPaymentType];
  }

  disableSubmit() {
    return this.loading()
      || this.state.submitting
      || !this.props.fundraiser.currentPaymentType
      || !this.props.fundraiser.donationAmount;
  }

  // this should actually be a selector (a fn that returns a slice of state)
  donationData() {
    const {
      fundraiser: {
        donationAmount,
        currency,
        recurring,
        storeInVault,
        form,
      }
    } = this.props;

    return {
      amount: donationAmount,
      currency: currency,
      recurring: recurring,
      store_in_vault: storeInVault,
      user: form,
    };
  }

  delegate() {
    const delegate = this.refs[this.props.fundraiser.currentPaymentType];

    if (delegate && delegate.submit) {
      return delegate;
    } else if (delegate && delegate.getWrappedInstance().submit) {
      return delegate.getWrappedInstance();
    }

    return null;
  }

  // to handle direct debit, which will probably be a bit different, we might need
  // to tweak this
  makePayment() {
    const delegate = this.delegate();

    this.setState({ submitting: true });

    if (delegate && delegate.submit) {
      delegate.submit().then(
        success => this.submit(success),
        reason => this.onError(reason),
      );
    } else {
      this.submit();
    }
  }

  submit(data) {
    const payload = {
      ...this.donationData(),
      payment_method_nonce: data.nonce,
      device_data: this.state.deviceData,
    };

    $.post(`/api/payment/braintree/pages/${this.props.fundraiser.pageId}/transaction`, payload)
      .then(
        success => this.onSuccess(success),
        reason => this.onError(reason)
      );
  }

  onSuccess(data) {
    console.log('success:', data);
  }

  onError(reason) {
    this.setState({ submitting: false });
  }

  render() {
    const {
      member,
      fundraiser: {
        currency,
        donationAmount,
        currentPaymentType,
        recurring,
        storeInVault,
        disableRecurring,
      }
    } = this.props;
    return (
      <div className="Payment section">
        <WelcomeMember member={this.props.member} resetMember={() => this.resetMember()} />
        <h3 className="Payment__prompt">
          <FormattedMessage
            id="fundraiser.payment_type_prompt"
            defaultMessage="How would you like to donate?" />
        </h3>
        <div className="Payment__options">
          <PaymentTypePill
            name="gocardless"
            disabled={this.state.loading}
            checked={currentPaymentType === 'gocardless'}
            onChange={() => this.selectPaymentType('gocardless')}>
            <FormattedMessage
              id="fundraiser.debit.direct_debit"
              defaultMessage="Direct Debit" />
          </PaymentTypePill>

          <PaymentTypePill
            name="paypal"
            disabled={this.state.loading}
            checked={currentPaymentType === 'paypal'}
            onChange={() => this.selectPaymentType('paypal')}>
            PayPal
          </PaymentTypePill>

          <PaymentTypePill
            name="card"
            disabled={this.state.loading}
            checked={currentPaymentType === 'card'}
            activeColor="#00c0cf"
            onChange={() => this.selectPaymentType('card')}>
            <FormattedMessage
              id="fundraiser.pay_by_card"
              defaultMessage="Credit or Debit Card" />
          </PaymentTypePill>
        </div>

        <PayPal
          ref="paypal"
          client={this.state.client}
          recurring={recurring}
          onInit={() => this.paymentInitialized('paypal')} />

        <BraintreeCardFields
          ref="card"
          client={this.state.client}
          recurring={recurring}
          isActive={currentPaymentType === 'card'}
          onInit={() => this.paymentInitialized('card')}
        />

        <hr className="Payment__divider" />

        <div className="Payment__config">
          <div className="Payment__form-group">
            <label className="Payment__form-group-label">
              <input
                type="checkbox"
                name="store_in_vault"
                disabled={disableRecurring}
                defaultChecked={recurring}
                onChange={(e) => this.props.setRecurring(e.currentTarget.checked)}
              />
              <FormattedMessage
                id="fundraiser.make_recurring"
                defaultMessage="Make my donation monthly" />
            </label>
          </div>

          <div className="Payment__form-group">
            <label className="Payment__form-group-label">
              <input
                type="checkbox"
                name="store_in_vault"
                defaultChecked={storeInVault}
                onChange={(e) => this.props.setStoreInVault(e.currentTarget.checked)}
              />
              <FormattedMessage
                id="fundraiser.store_in_vault"
                defaultMessage="Securely store my payment information" />
            </label>
          </div>
        </div>

        <Button className="Payment__submit" onClick={this.makePayment.bind(this)} disabled={this.disableSubmit()}>

          { this.loading() && <FormattedMessage id="loading" defaultMessage="Loading..." />}

          { !this.loading() && <span className="fa fa-lock" />}
          { !this.loading() && <FormattedMessage
              id="fundraiser.donate"
              defaultMessage="Donate {amount}"
              values={{
                amount: (
                  <FormattedNumber {...FORMATTED_NUMBER_DEFAULTS}
                    currency={currency}
                    value={donationAmount || 0} />
                )
              }} />
          }
        </Button>

        <div className="Payment__fine-print">
          <FormattedMessage
            className="Payment__fine-print"
            id="fundraiser.fine_print"
            defaultMessage="SumOfUs is a registered 501(c)4 non-profit incorporated in Washington, DC, United States. Contributions or gifts to SumOfUs are not tax deductible. For further information, please contact info@sumofus.org."
          />
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state: AppState) => ({
  fundraiser: state.fundraiser,
  member: state.member,
  disableRecurring: state.fundraiser.recurringDefault === 'only_recurring',
});

const mapDispatchToProps = dispatch => ({
  resetMember: () => dispatch(resetMember()),
  changeStep: (step: number) => dispatch(changeStep(step)),
  setRecurring: (value: boolean) => dispatch(setRecurring(value)),
  setStoreInVault: (value: boolean) => dispatch(setStoreInVault(value)),
  setPaymentType: (value: ?string) => dispatch(setPaymentType(value)),
});

export default connect(mapStateToProps, mapDispatchToProps)(Payment);
