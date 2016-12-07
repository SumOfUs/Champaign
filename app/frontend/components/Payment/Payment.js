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
    fetch('/api/payment/braintree/token')
      .then(response => response.json())
      .then(data => {
        braintreeClient.create({ authorization: data.token }, (error, client) => {
          // todo: handle err?
          console.log('bt init error:', error);
          dataCollector.create({
            client,
            kount: true,
            paypal: true,
          }, (err, collectorInst) => {
            if (err) {
              console.log(err, collectorInst);
              return;
            }

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
    this.props.changeStep(this.props.currentStep - 1);
  }

  paymentMethodReady() {
    return this.state.paymentMethods[this.state.paymentMethod].ready;
  }

  paymentInitialized(name: string) {
    this.setState({ initializing: { ...this.state.initializing, [name]: false } });
  }

  loading() {
    return this.state.loading || this.state.initializing[this.props.currentPaymentType];
  }

  disableSubmit() {
    return this.loading()
      || this.state.submitting
      || !this.props.currentPaymentType
      || !this.props.donationAmount;
  }

  render() {
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
            checked={this.props.currentPaymentType === 'gocardless'}
            onChange={() => this.selectPaymentType('gocardless')}>
            <FormattedMessage
              id="fundraiser.debit.direct_debit"
              defaultMessage="Direct Debit" />
          </PaymentTypePill>

          <PaymentTypePill
            name="paypal"
            disabled={this.state.loading}
            checked={this.props.currentPaymentType === 'paypal'}
            onChange={() => this.selectPaymentType('paypal')}>
            PayPal
          </PaymentTypePill>

          <PaymentTypePill
            name="card"
            disabled={this.state.loading}
            checked={this.props.currentPaymentType === 'card'}
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
          recurring={this.props.recurring}
          onInit={() => this.paymentInitialized('paypal')} />

        <BraintreeCardFields
          ref="card"
          client={this.state.client}
          recurring={this.props.recurring}
          isActive={this.props.currentPaymentType === 'card'}
          onInit={() => this.paymentInitialized('card')}
        />

        <hr className="Payment__divider" />

        <div className="Payment__config">
          <div className="Payment__form-group">
            <label className="Payment__form-group-label">
              <input
                type="checkbox"
                name="store_in_vault"
                disabled={this.props.disableRecurring}
                defaultChecked={this.props.recurring}
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
                defaultChecked={this.props.storeInVault}
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
                    currency={this.props.currency}
                    value={this.props.donationAmount || 0} />
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

  donationData() {
    return {
      amount: this.props.donationAmount,
      currency: this.props.currency,
      recurring: this.props.recurring,
      store_in_vault: this.props.storeInVault,
      user: this.props.user,
    };
  }

  delegate() {
    const delegate = this.refs[this.props.currentPaymentType];

    if (delegate && delegate.submit) {
      return delegate;
    } else if (delegate && delegate.getWrappedInstance().submit) {
      return delegate.getWrappedInstance();
    }

    return null;
  }

  makePayment() {
    const delegate = this.delegate();

    this.setState({ submitting: true });

    if (delegate && delegate.submit) {
      console.log('calling delegated payment fn...');
      delegate.submit().then(
        success => this.submit(success),
        reason => this.onError(reason),
      );
    } else {
      console.log('calling calling submit directly...');
      this.submit();
    }
  }

  submit(data) {
    console.log('submitting to chmpgn', data);
    fetch(`/api/payment/braintree/pages/${this.props.pageId}/transaction`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        accept: 'application/json',
      },
      body: JSON.stringify({
        ...this.donationData(),
        payment_method_nonce: data.nonce,
        device_data: this.state.deviceData,
      })
    })
      .then(resp => resp.json(), reason => this.onError(reason))
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
    console.log('failed with:', reason);
  }
}

const mapStateToProps = (state: AppState) => ({
  currency: state.fundraiser.currency,
  donationAmount: state.fundraiser.donationAmount,
  member: state.member,
  user: state.fundraiser.user,
  currentStep: state.fundraiser.currentStep,
  recurring: state.fundraiser.recurring,
  disableRecurring: state.fundraiser.recurringDefault === 'only_recurring',
  storeInVault: state.fundraiser.storeInVault,
  currentPaymentType: state.fundraiser.currentPaymentType,
  pageId: state.fundraiser.pageId,
});

const mapDispatchToProps = dispatch => ({
  resetMember: () => dispatch(resetMember()),
  changeStep: (step: number) => dispatch(changeStep(step)),
  setRecurring: (value: boolean) => dispatch(setRecurring(value)),
  setStoreInVault: (value: boolean) => dispatch(setStoreInVault(value)),
  setPaymentType: (value: ?string) => dispatch(setPaymentType(value)),
});

export default connect(mapStateToProps, mapDispatchToProps)(Payment);
