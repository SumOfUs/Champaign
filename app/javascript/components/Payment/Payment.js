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
import ReCaptchaBranding from '../ReCaptchaBranding';
import { resetMember } from '../../state/member/reducer';
import Cookie from 'js-cookie';
import CurrencyAmount from '../CurrencyAmount';
import WeeklyDonationFinePrint from '../WeeklyDonationFinePrint';

import {
  changeStep,
  setRecurring,
  setStoreInVault,
  setPaymentType,
} from '../../state/fundraiser/actions';
import ExpressDonation from '../ExpressDonation/ExpressDonation';
import { isDirectDebitSupported } from '../../util/directDebitDecider';

// Styles
import './Payment.css';

const BRAINTREE_TOKEN_URL =
  process.env.BRAINTREE_TOKEN_URL || '/api/payment/braintree/token';

export class Payment extends Component {
  static title = (<FormattedMessage id="payment" defaultMessage="payment" />);

  constructor(props) {
    super(props);
    this.state = {
      client: null,
      deviceData: {},
      loading: true,
      submitting: false,
      expressHidden: false,
      recurringDonor: false,
      recurringDefault: null,
      pageDefault: null,
      onlyRecurring: false,
      akid: null,
      source: null,
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
    const urlInfo = window.champaign.personalization.urlParams;
    const donor_status = window.champaign.personalization.member?.donor_status;
    const pageDefault =
      window.champaign.plugins.fundraiser?.default?.config.recurring_default;
    const normalizedRecurringDefault = urlInfo.recurring_default || pageDefault;

    this.setState({
      recurringDonor: donor_status === 'recurring_donor',
      akid: urlInfo.akid,
      source: urlInfo.source,
      onlyRecurring: normalizedRecurringDefault === 'only_recurring',
      recurringDefault: normalizedRecurringDefault,
      pageDefault,
    });

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
    // set default payment type for existing user
    this.setDefaultPaymentType();
  }

  // set default payment as DirectDebit / paypal when the
  // user follows external link like email
  setDefaultPaymentType = () => {
    const urlInfo = window.champaign.personalization.urlParams;
    const country = this.props.fundraiser.form.country;
    const showDirectDebit = isDirectDebitSupported({ country: country });
    const lang = window.champaign.page.language_code;

    if (urlInfo.akid && this.props.fundraiser.recurring && lang == 'de') {
      if (showDirectDebit) {
        this.selectPaymentType('gocardless');
      } else {
        this.selectPaymentType('paypal');
      }
    }
  };

  bindGlobalEvents() {
    ee.on('fundraiser:actions:make_payment', this.makePayment);
    // set default payment type for new user
    ee.on('fundraiser:form:success', this.setDefaultPaymentType);
  }

  componentDidUpdate() {
    ee.emit('sidebar:height_change');
  }

  selectPaymentType(paymentType) {
    if (window.screen.height < 650) {
      const bar = document.getElementsByClassName('fundraiser-bar__content')[0];
      bar.scrollTo(0, 201);
    }
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

  getMemberName(member, formValues) {
    if (member) {
      return `${member.fullName}:`;
    } else if (formValues && formValues.member) {
      return `${formValues.member.name}:`;
    } else {
      return null;
    }
  }

  removeRecurringPropertyListener() {
    ee.removeListener('fundraiser:change_recurring', this.makePayment, this);
  }

  onClickHandle(e) {
    const isRecurring = e.currentTarget.name === 'recurring';
    this.props.setRecurring(isRecurring);
    ee.on('fundraiser:change_recurring', this.makePayment, this);
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
      amount: this.props.weekly ? donationAmount * 4 : donationAmount,
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
      source: window.champaign.personalization.urlParams.source,
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
    const userId =
      window.champaign.personalization.member.id || Cookie.get('__bpmx');
    const eventPayload = {
      user_id: userId,
      page_id: this.props.page.id,
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

  makePayment = event => {
    if (this.props.currentPaymentType === 'gocardless') {
      this.submitGoCardless();
      return;
    }
    const delegate = this.delegate();
    this.props.setSubmitting(true);
    if (delegate && delegate.submit) {
      delegate.submit().then(
        success => this.submit(success),
        reason => this.onError(reason)
      );
    } else {
      this.submit();
    }
    this.removeRecurringPropertyListener();
  };

  submit = async data => {
    const recaptcha_action = `donate/${this.props.page.id}`;
    const recaptcha_token = await captcha.execute({ action: recaptcha_action });

    const payload = {
      ...this.donationData(),
      payment_method_nonce: data.nonce,
      device_data: this.state.deviceData,
      source: window.champaign.personalization.urlParams.source,
      recaptcha_token,
      recaptcha_action,
    };

    this.emitTransactionSubmitted();

    $.post(
      `/api/payment/braintree/pages/${this.props.page.id}/transaction`,
      payload
    ).then(this.onSuccess, this.onBraintreeError);
  };

  onSuccess = data => {
    if (typeof window.fbq === 'function') {
      const userId =
        window.champaign.personalization.member.id || Cookie.get('__bpmx');
      window.fbq('track', 'Purchase', {
        user_id: userId,
        page_id: this.props.page.id,
        value: this.props.fundraiser.donationAmount,
        currency: this.props.fundraiser.currency,
        content_name: this.props.page.title,
        content_ids: [this.props.page.id],
        content_type: 'product',
        product_catalog_id: 445876772724152,
        donation_type: this.props.fundraiser.recurring
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
      window.mixpanel.track('donation-made', {
        event_label: 'saved-payment-info',
        event_source: 'fa_fundraising',
      });
    }
    emitTransactionSuccess();

    this.setState({ errors: [] });
  };

  onError = reason => {
    const errorParsed =
      reason && reason.responseText && JSON.parse(reason.responseText);
    const fundraiserBar = document.getElementsByClassName(
      'fundraiser-bar__content'
    )[0];
    if (
      (errorParsed && errorParsed.success === false) ||
      !isEmpty(this.state.errors)
    ) {
      setTimeout(() => {
        fundraiserBar.scrollTo(0, 0);
      }, 500);
    }
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

  //  Recurring Donor can see only One off donation button
  //  Recurring Donor cannot have multiple subscriptions.
  //  So a member who becomes a recurring_donor via subscribing
  //  any page cannot see a monthly donation button at any circumstance
  //  again. Instead he can see One time donation button alone
  //  A non recurring donor can see
  //   - only monthly payment button for 'only_recurring' page
  //   - else both buttons should be displayed
  //   - he cannot see monthly donation button when the url has akid & source=fwd

  showMonthlyButton() {
    if (this.state.recurringDonor) {
      return false;
    } else {
      if (this.state.recurringDefault === 'only_one_off') {
        return false;
      }
      return true;
    }
  }

  showOneOffButton() {
    if (this.state.recurringDonor) {
      return true;
    } else {
      if (this.state.recurringDefault === 'only_one_off') {
        return true;
      }

      if (this.state.recurringDefault === 'only_recurring') {
        return false;
      }
      return true;
    }
  }

  render() {
    const {
      member,
      onlyRecurring,
      recurringDonor,
      formData,
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
          showOneOffButton={this.showOneOffButton()}
          showMonthlyButton={this.showMonthlyButton()}
          weekly={this.props.weekly}
          data={{
            src: this.state.src,
            akid: this.state.akid,
            recurringDefault: this.state.recurringDefault,
            onlyRecurring: this.state.onlyRecurring,
            recurringDonor: this.state.recurringDonor,
          }}
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
          {/*
          {this.showMonthlyButton() && (
            <Checkbox
              className="Payment__config"
              disabled={!this.showMonthlyButton()}
              checked={recurring}
              onChange={e => this.props.setRecurring(e.currentTarget.checked)}
            >
              <FormattedMessage
                id="fundraiser.make_recurring"
                defaultMessage="Make my donation monthly"
              />
            </Checkbox>
          )} */}

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

          <div className="payment-message">
            <br />
            {!this.state.recurringDonor && (
              <FormattedMessage
                id={'fundraiser.make_monthly_donation'}
                defaultMessage={`{name} a monthly donation will support our movement to plan ahead, so we can more effectively take on the biggest corporations that threaten people and planet.`}
                values={{
                  name: this.getMemberName(member, formData),
                  duration: this.props.weekly ? 'weekly' : 'monthly',
                }}
              />
            )}

            <div className="PaymentMethod__complete-donation">
              <FormattedMessage
                id={'fundraiser.complete_donation'}
                defaultMessage={`Complete your {amount} donation`}
                values={{
                  amount: (
                    <CurrencyAmount
                      amount={donationAmount || 0}
                      currency={currency}
                    />
                  ),
                }}
              />
            </div>

            {/* <div className="PaymentMethod__complete-donation donation-amount-text-2x">
              <FormattedMessage
                id={'fundraiser.donate_amount'}
                defaultMessage={`Donate {amount}`}
                className=""
                values={{
                  amount: (
                    <CurrencyAmount
                      amount={donationAmount || 0}
                      currency={currency}
                    />
                  ),
                }}
              />
            </div> */}
          </div>

          {currentPaymentType === 'paypal' && (
            <div className="PaymentMethod__guidance">
              <FormattedMessage
                id={'fundraiser.payment_methods.ready_for_paypal'}
              />
            </div>
          )}

          <>
            <ShowIf condition={this.showMonthlyButton()}>
              <DonateButton
                currency={currency}
                amount={donationAmount || 0}
                submitting={this.state.submitting}
                name="recurring"
                recurring={true}
                recurringDonor={this.state.recurringDonor}
                weekly={this.props.weekly}
                disabled={this.disableSubmit()}
                onClick={e => this.onClickHandle(e)}
              />
            </ShowIf>

            <ShowIf condition={this.showOneOffButton()}>
              <DonateButton
                currency={currency}
                amount={donationAmount || 0}
                submitting={this.state.submitting}
                name="one_time"
                recurring={false}
                recurringDonor={this.state.recurringDonor}
                disabled={this.disableSubmit()}
                onClick={e => this.onClickHandle(e)}
              />
            </ShowIf>
          </>
        </ShowIf>

        <div className="Payment__fine-print">
          {this.props.weekly && this.showMonthlyButton() && (
            <WeeklyDonationFinePrint className="ReCaptchaBranding mb-10" />
          )}
          <FormattedHTMLMessage
            className="Payment__fine-print"
            id="fundraiser.fine_print"
            defaultMessage={`
              SumOfUs is a registered 501(c)4 non-profit incorporated in Washington, DC, United
              States. Contributions or gifts to SumOfUs are not tax deductible.
              For further information, please contact info@sumofus.org.
            `}
          />
          <ReCaptchaBranding />
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
  weekly: window.champaign.personalization.urlParams.weekly,
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
  onlyRecurring: state.fundraiser.recurringDefault === 'only_recurring',
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

export default connect(mapStateToProps, mapDispatchToProps)(Payment);
