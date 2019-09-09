import $ from 'jquery';
import React, { Component } from 'react';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import { connect } from 'react-redux';
import braintreeClient from 'braintree-web/client';
import dataCollector from 'braintree-web/data-collector';
import { isEmpty } from 'lodash';
import ee from '../../shared/pub_sub';
import captcha from '../../shared/recaptcha';

import PayPal from '../Braintree/PayPal';
import BraintreeCardFields from '../Braintree/BraintreeCardFields';
import PaymentTypeSelection from './PaymentTypeSelection';
import WelcomeMember from '../WelcomeMember/WelcomeMember';
import DonateButton from '../DonateButton';
import Checkbox from '../Checkbox/Checkbox';
import ShowIf from '../ShowIf';
import { resetMember } from '../../state/member/reducer';
import {
  changeStep,
  setRecurring,
  setStoreInVault,
  setPaymentType,
} from '../../state/fundraiser/actions';
import ExpressDonation from '../ExpressDonation/ExpressDonation';

// Styles
import './Payment.css';

const BRAINTREE_TOKEN_URL =
  process.env.BRAINTREE_TOKEN_URL || '/api/payment/braintree/token';

export class Payment extends Component {
  static title = <FormattedMessage id="payment" defaultMessage="payment" />;

  constructor(props) {
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
      errors: [],
      waitingForGoCardless: false,
    };
  }

  componentDidMount() {
    $.get(BRAINTREE_TOKEN_URL)
      .done(data => {
        braintreeClient.create(
          { authorization: data.token },
          (error, client) => {
            // todo: handle err?
            dataCollector.create(
              {
                client,
                kount: true,
                paypal: true,
              },
              (err, collectorInst) => {
                if (err) {
                  return this.setState({ client, loading: false });
                }

                const deviceData = collectorInst.deviceData;
                this.setState({
                  client,
                  deviceData: JSON.parse(deviceData),
                  loading: false,
                });
              }
            );
          }
        );
      })
      .fail(failure => {
        console.warn('could not fetch Braintree token');
      });
    this.bindGlobalEvents();
  }

  bindGlobalEvents() {
    ee.on('fundraiser:actions:make_payment', this.makePayment);
  }

  componentDidUpdate() {
    ee.emit('sidebar:height_change');
  }

  selectPaymentType(paymentType) {
    this.props.setPaymentType(paymentType);
  }

  resetMember() {
    this.props.resetMember();
  }

  paymentInitialized(name) {
    this.setState({
      initializing: { ...this.state.initializing, [name]: false },
    });
  }

  loading(paymentType) {
    const loading = this.state.loading;
    if (paymentType) {
      return loading || this.state.initializing[paymentType];
    } else {
      return loading;
    }
  }

  disableSubmit() {
    return (
      this.loading(this.props.currentPaymentType) ||
      !this.props.currentPaymentType ||
      !this.props.fundraiser.donationAmount
    );
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
      extraActionFields,
    } = this.props;

    return {
      amount: donationAmount,
      currency: currency,
      recurring: recurring,
      store_in_vault: storeInVault,
      user: {
        ...formValues,
        ...form,
      },
      extra_action_fields: extraActionFields,
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

  submitGoCardless() {
    const payload = {
      ...this.donationData(),
      device_data: this.state.deviceData,
      provider: 'GC',
    };
    const url = `/api/go_cardless/pages/${
      this.props.page.id
    }/start_flow?${$.param(payload)}`;
    window.open(url);

    this.emitTransactionSubmitted();

    if (!this.state.waitingForGoCardless) {
      window.addEventListener('message', this.waitForGoCardless.bind(this));
      this.setState({ waitingForGoCardless: true });
    }
  }

  waitForGoCardless(event) {
    if (typeof event.data === 'object') {
      if (event.data.event === 'follow_up:loaded') {
        event.source.close();
        ee.emit('direct_debit:donated');
        this.onSuccess({});
      } else if (event.data.event === 'donation:error') {
        const messages = event.data.errors.map(({ message }) => message);
        this.onError(messages);
        event.source.close();
      }
    }
  }

  emitTransactionSubmitted() {
    const eventPayload = {
      value: this.props.fundraiser.donationAmount,
      currency: this.props.fundraiser.currency,
      content_category: this.props.currentPaymentType,
      recurring: this.props.fundraiser.recurring,
    };

    if (typeof window.fbq === 'function') {
      window.fbq('track', 'AddPaymentInfo', eventPayload);
    }

    ee.emit(
      'fundraiser:transaction_submitted',
      eventPayload,
      this.props.formData
    );
  }

  makePayment = () => {
    if (this.props.currentPaymentType === 'gocardless') {
      this.submitGoCardless();
      return;
    }
    const delegate = this.delegate();
    this.props.setSubmitting(true);
    if (delegate && delegate.submit) {
      delegate
        .submit()
        .then(success => this.submit(success), reason => this.onError(reason));
    } else {
      this.submit();
    }
  };

  submit = async data => {
    const recaptcha_action = `donate/${this.props.page.id}`;
    const recaptcha_token = await captcha.execute({ action: recaptcha_action });

    const payload = {
      ...this.donationData(),
      payment_method_nonce: data.nonce,
      device_data: this.state.deviceData,
      recaptacha_token,
      recaptacha_action,
    };

    this.emitTransactionSubmitted();

    $.post(
      `/api/payment/braintree/pages/${this.props.page.id}/transaction`,
      payload
    ).then(this.onSuccess, this.onBraintreeError);
  };

  onSuccess = data => {
    if (typeof window.fbq === 'function') {
      window.fbq('track', 'Purchase', {
        value: this.props.fundraiser.donationAmount,
        currency: this.props.fundraiser.currency,
        content_name: this.props.page.title,
        content_ids: [this.props.page.id],
        content_type: this.props.fundraiser.recurring
          ? 'recurring'
          : 'not_recurring',
      });
    }

    const emitTransactionSuccess = () => {
      ee.emit('fundraiser:transaction_success', data, this.props.formData);
    };

    if (
      typeof window.mixpanel !== 'undefined' &&
      this.props.fundraiser.storeInVault
    ) {
      window.mixpanel.track(
        'donation-made',
        {
          event_label: 'saved-payment-info',
          event_source: 'fa_fundraising',
        },
        emitTransactionSuccess
      );
    } else {
      emitTransactionSuccess();
    }

    this.setState({ errors: [] });
  };

  onError = reason => {
    ee.emit('fundraiser:transaction_error', reason, this.props.formData);
    this.props.setSubmitting(false);
  };

  onBraintreeError = response => {
    let errors;
    if (
      response.status === 422 &&
      response.responseJSON &&
      response.responseJSON.errors
    ) {
      errors = response.responseJSON.errors.map(function(error) {
        if (error.declined) {
          return <FormattedMessage id="fundraiser.card_declined" />;
        } else {
          return error.message;
        }
      });
    } else {
      errors = [<FormattedMessage id="fundraiser.unknown_error" />];
    }
    this.setState({ errors: errors });
    this.onError(response);
  };

  isExpressHidden() {
    return this.state.expressHidden || this.props.disableSavedPayments;
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
      },
    } = this.props;

    return (
      <div className="Payment section">
        <ShowIf condition={!isEmpty(this.state.errors)}>
          <div className="fundraiser-bar__errors">
            <div className="fundraiser-bar__error-intro">
              <span className="fa fa-exclamation-triangle" />
              <FormattedMessage
                id="fundraiser.error_intro"
                defaultMessage="Unable to process donation!"
              />
            </div>
            {this.state.errors.map((e, i) => {
              return (
                <div key={i} className="fundraiser-bar__error-detail">
                  {e}
                </div>
              );
            })}
          </div>
        </ShowIf>

        {!this.props.disableFormReveal && (
          <WelcomeMember
            member={member}
            resetMember={() => this.resetMember()}
          />
        )}

        <ExpressDonation
          setSubmitting={s => this.props.setSubmitting(s)}
          hidden={this.isExpressHidden()}
          onHide={() => this.setState({ expressHidden: true })}
        />

        <ShowIf condition={this.isExpressHidden()}>
          <PaymentTypeSelection
            disabled={this.state.loading}
            onChange={p => this.selectPaymentType(p)}
          />

          <PayPal
            ref="paypal"
            amount={donationAmount}
            currency={currency}
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

          {currentPaymentType === 'gocardless' && (
            <div className="PaymentMethod__guidance">
              <FormattedMessage
                id={'fundraiser.payment_methods.ready_for_gocardless'}
              />
            </div>
          )}

          {!hideRecurring && (
            <Checkbox
              className="Payment__config"
              disabled={hideRecurring}
              checked={recurring}
              onChange={e => this.props.setRecurring(e.currentTarget.checked)}
            >
              <FormattedMessage
                id="fundraiser.make_recurring"
                defaultMessage="Make my donation monthly"
              />
            </Checkbox>
          )}

          <Checkbox
            className="Payment__config"
            checked={storeInVault}
            onChange={e => this.props.setStoreInVault(e.currentTarget.checked)}
          >
            <FormattedMessage
              id="fundraiser.store_in_vault"
              defaultMessage="Securely store my payment information"
            />
          </Checkbox>

          {currentPaymentType === 'paypal' && (
            <div className="PaymentMethod__guidance">
              <FormattedMessage
                id={'fundraiser.payment_methods.ready_for_paypal'}
              />
            </div>
          )}
          <DonateButton
            currency={currency}
            amount={donationAmount || 0}
            submitting={this.state.submitting}
            recurring={recurring}
            disabled={this.disableSubmit()}
            onClick={this.makePayment}
          />
        </ShowIf>

        <div className="Payment__fine-print">
          <FormattedHTMLMessage
            className="Payment__fine-print"
            id="fundraiser.fine_print"
            defaultMessage={`
              SumOfUs is a registered 501(c)4 non-profit incorporated in Washington, DC, United
              States. Contributions or gifts to SumOfUs are not tax deductible.
              For further information, please contact info@sumofus.org.
            `}
          />
        </div>

        {this.props.showDirectDebit && (
          <div className="Payment__direct-debit-logo">
            <img src={require('./dd_logo_landscape.png')} alt="DIRECT Debit" />
          </div>
        )}
      </div>
    );
  }
}

const mapStateToProps = state => ({
  disableSavedPayments:
    state.fundraiser.disableSavedPayments || state.paymentMethods.length === 0,
  defaultPaymentType: state.fundraiser.directDebitOnly ? 'gocardless' : 'card',
  showDirectDebit: state.fundraiser.showDirectDebit,
  currentPaymentType: state.fundraiser.directDebitOnly
    ? 'gocardless'
    : state.fundraiser.currentPaymentType,
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
  },
  extraActionFields: state.extraActionFields,
});

const mapDispatchToProps = dispatch => ({
  resetMember: () => dispatch(resetMember()),
  changeStep: step => dispatch(changeStep(step)),
  setRecurring: value => dispatch(setRecurring(value)),
  setStoreInVault: value => dispatch(setStoreInVault(value)),
  setPaymentType: value => dispatch(setPaymentType(value)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Payment);
