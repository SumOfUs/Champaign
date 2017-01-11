// @flow
import React, { Component } from 'react';
import $ from '../../util/PubSub';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import braintreeClient from 'braintree-web/client.debug';
import dataCollector from 'braintree-web/data-collector';
import _ from 'lodash';

import PayPal from '../Braintree/PayPal';
import BraintreeCardFields from '../Braintree/BraintreeCardFields';
import PaymentTypeSelection from './PaymentTypeSelection';
import WelcomeMember from '../WelcomeMember/WelcomeMember';
import DonateButton from '../DonateButton';
import Checkbox from '../Checkbox/Checkbox';
import ShowIf from '../ShowIf';
import { resetMember } from '../../state/member/actions';
import { changeStep, setRecurring, setStoreInVault, setPaymentType } from '../../state/fundraiser/actions';
import ExpressDonation from '../ExpressDonation/ExpressDonation';

import type { Dispatch } from 'redux';
import type { BraintreeClient } from 'braintree-web';
import type { AppState, Member, FundraiserState, PaymentMethod } from '../../state';

// Styles
import './Payment.css';

const DEFAULT_PAYMENT_TYPE = 'card';

type OwnProps = {
  member: Member;
  fundraiser: FundraiserState;
  paymentMethods: PaymentMethod[],
  hideRecurring: boolean;
  disableFormReveal: boolean;
  formData: { member: any; storeInVault: boolean; };
  resetMember: () => void;
  changeStep: (step: number) => void;
  setRecurring: (value: boolean) => void;
  setStoreInVault: (value: boolean) => void;
  setPaymentType: (value: ?string) => void;
};

type OwnState = {
  client: BraintreeClient;
  deviceData: Object;
  loading: boolean;
  submitting: boolean;
  expressHidden: boolean;
  initializing: {
    gocardless: boolean;
    paypal: boolean;
    card: boolean;
  };
  errors: string[];
};
export class Payment extends Component {
  props: OwnProps;
  state: OwnState;

  static title = <FormattedMessage id="payment" defaultMessage="payment" />;

  constructor(props: OwnProps) {
    super(props);
    this.state = {
      client: null,
      deviceData: {},
      loading: true,
      submitting: false,
      expressHidden: false,
      initializing: {
        gocardless: false,
        paypal: true,
        card: true,
      },
      errors: []
    };

    const cpt = this.props.fundraiser.currentPaymentType;
    if (typeof cpt !== 'string' || cpt.length === 0) {
      this.props.setPaymentType(DEFAULT_PAYMENT_TYPE); }
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

  loading(paymentType: ?string) {
    const loading = this.state.loading || this.state.submitting;
    if (paymentType) {
      return loading || this.state.initializing[paymentType];
    } else {
      return loading;
    }
  }

  disableSubmit() {
    return this.loading(this.props.fundraiser.currentPaymentType)
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
        formValues,
      },
    } = this.props;

    return {
      amount: donationAmount,
      currency: currency,
      recurring: recurring,
      store_in_vault: storeInVault,
      user: {
        ...formValues,
        ...form
      },
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

  submitGoCardless() {
    const payload = {
      ...this.donationData(),
      device_data: this.state.deviceData,
      provider: 'GC',
    };
    console.log(payload);
    const url = `/api/go_cardless/pages/${this.props.fundraiser.pageId}/start_flow?${$.param(payload)}`;
    window.open(url);

    if (!this.waitingForGoCardless) {
      window.addEventListener('message', this.waitForGoCardless.bind(this));
      this.waitingForGoCardless = true;
    }
  }

  waitForGoCardless(event) {
    if (typeof event.data === 'object') {
      if (event.data.event === 'follow_up:loaded') {
        event.source.close();
        $.publish('direct_debit:donated');
        this.onSuccess({});
      } else if (event.data.event === 'donation:error') {
        const messages = event.data.errors.map(({ message }) => message);
        this.onError(messages);
        event.source.close();
      }
    }
  }

  makePayment() {
    if (this.props.fundraiser.currentPaymentType === 'gocardless') {
      this.submitGoCardless();
      return;
    }
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

  submit(data: any) {
    const payload = {
      ...this.donationData(),
      payment_method_nonce: data.nonce,
      device_data: this.state.deviceData,
    };

    $.post(`/api/payment/braintree/pages/${this.props.fundraiser.pageId}/transaction`, payload)
      .then(this.onSuccess.bind(this), this.onBraintreeError.bind(this));
  }

  onSuccess(data: any) {
    console.log('success:', data);
    $.publish('fundraiser:transaction_success', [data, this.props.formData]);
    this.setState({ errors: [] });
  }

  onError(reason: any) {
    $.publish('fundraiser:transaction_error', [reason, this.props.formData]);
    this.setState({ submitting: false});
  }

  onBraintreeError(response: any) {
    let errors;
    if (response.status === 422 && response.responseJSON && response.responseJSON.errors) {
      errors = response.responseJSON.errors.map(function(error){
        if (error.declined) {
          return <FormattedMessage id="fundraiser.card_declined"/>;
        } else {
          return error.message;
        }
      });
    } else {
      errors = [<FormattedMessage id="fundraiser.unknown_error" />];
    }
    this.setState({ errors: errors });
    this.onError(response);
  }

  render() {
    const {
      member,
      hideRecurring,
      fundraiser: {
        currency,
        donationAmount,
        currentPaymentType,
        recurring,
        storeInVault,
      }
    } = this.props;

    return (
      <div className="Payment section">
        <ShowIf condition={!_.isEmpty(this.state.errors)}>
          <div className="fundraiser-bar__errors">
            <span className="fa fa-exclamation-triangle"></span>
            <div className="fundraiser-bar__error-intro">
              <FormattedMessage id="fundraiser.error_intro" defaultMessage="Unable to process donation!" />
              {
                this.state.errors.map((e, i) => {
                  return <div key={i} className="fundraiser-bar__error-detail">{e}</div>;
                })
              }
            </div>
          </div>
        </ShowIf>

        { !this.props.disableFormReveal &&
          <WelcomeMember member={member} resetMember={() => this.resetMember()} />
        }

        <ExpressDonation
          hidden={this.state.expressHidden || this.props.paymentMethods.length === 0}
          onHide={() => this.setState({ expressHidden: true })}
        />

        <ShowIf condition={this.state.expressHidden || this.props.paymentMethods.length === 0}>
          <PaymentTypeSelection
            disabled={this.state.loading}
            currentPaymentType={currentPaymentType || DEFAULT_PAYMENT_TYPE}
            onChange={(p) => this.selectPaymentType(p)}
            showDirectDebit={this.props.fundraiser.showDirectDebit}
          />

          <PayPal
            ref="paypal"
            client={this.state.client}
            vault={recurring || storeInVault}
            onInit={() => this.paymentInitialized('paypal')}
          />

          <BraintreeCardFields
            ref="card"
            client={this.state.client}
            recurring={recurring}
            isActive={currentPaymentType === 'card'}
            onInit={() => this.paymentInitialized('card')}
          />

          { currentPaymentType === 'paypal' &&
            <div className="PaymentMethod__guidance">
              <FormattedMessage id={'fundraiser.payment_methods.ready_for_paypal'} />
            </div>
          }

          { currentPaymentType === 'gocardless' &&
            <div className="PaymentMethod__guidance">
              <FormattedMessage id={'fundraiser.payment_methods.ready_for_gocardless'} />
            </div>
          }

          { !hideRecurring &&
            <Checkbox
              className="Payment__config"
              disabled={hideRecurring}
              defaultChecked={recurring}
              onChange={(e) => this.props.setRecurring(e.target.checked)}>
              <FormattedMessage id="fundraiser.make_recurring" defaultMessage="Make my donation monthly" />
            </Checkbox>
          }

          <Checkbox
            className="Payment__config"
            defaultChecked={storeInVault}
            onChange={(e) => this.props.setStoreInVault(e.target.checked)}>
            <FormattedMessage id="fundraiser.store_in_vault" defaultMessage="Securely store my payment information" />
          </Checkbox>

          <DonateButton
            currency={currency}
            amount={donationAmount || 0}
            submitting={this.state.submitting}
            recurring={recurring}
            disabled={this.disableSubmit()}
            onClick={() => this.makePayment()}
            />
        </ShowIf>

        <div className="Payment__fine-print">
          <FormattedMessage
            className="Payment__fine-print"
            id="fundraiser.fine_print"
            defaultMessage={`
              SumOfUs is a registered 501(c)4 non-profit incorporated in Washington, DC, United
              States. Contributions or gifts to SumOfUs are not tax deductible.
              For further information, please contact info@sumofus.org.
            `}
          />
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state: AppState) => ({
  fundraiser: state.fundraiser,
  paymentMethods: state.paymentMethods,
  member: state.member,
  hideRecurring: state.fundraiser.recurringDefault === 'only_recurring',
  formData: {
    storeInVault: state.fundraiser.storeInVault,
    member: {
      ...state.fundraiser.formValues,
      ...state.fundraiser.form,
    },
  }
});

const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  resetMember: () => dispatch(resetMember()),
  changeStep: (step: number) => dispatch(changeStep(step)),
  setRecurring: (value: boolean) => dispatch(setRecurring(value)),
  setStoreInVault: (value: boolean) => dispatch(setStoreInVault(value)),
  setPaymentType: (value: ?string) => dispatch(setPaymentType(value)),
});

export default connect(mapStateToProps, mapDispatchToProps)(Payment);
