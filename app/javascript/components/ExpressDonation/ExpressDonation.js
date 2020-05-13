import $ from 'jquery';
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import ee from '../../shared/pub_sub';
import Checkbox from '../Checkbox/Checkbox';
import DonateButton from '../DonateButton';
import PaymentMethodWrapper from './PaymentMethodWrapper';
import PaymentMethodItem from './PaymentMethod';
import { setRecurring } from '../../state/fundraiser/actions';
import CurrencyAmount from '../CurrencyAmount';

import Popup from 'reactjs-popup';
import Button from '../../components/Button/Button';

import './ExpressDonation.scss';

const style = {
  width: 'auto',
  padding: 30,
};

export class ExpressDonation extends Component {
  constructor(props) {
    super(props);

    this.state = {
      currentPaymentMethod: props.paymentMethods
        ? props.paymentMethods[0]
        : null,
      submitting: false,
      openPopup: false,
      recurringDonor: false,
      recurringDefault: null,
      onlyRecurring: false,
      akid: null,
      source: null,
      optForRedonation: false,
      failureReason: '',
    };
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

  oneClickData() {
    if (!this.state.currentPaymentMethod) return null;

    return {
      payment: {
        currency: this.props.fundraiser.currency,
        amount: this.props.fundraiser.donationAmount,
        recurring: this.props.fundraiser.recurring,
        payment_method_id: this.state.currentPaymentMethod.id,
      },
      user: {
        form_id: this.props.fundraiser.formId,
        // formValues will have the prefillValues
        ...this.props.fundraiser.formValues,
        // form will have the user's submitted values
        ...this.props.fundraiser.form,
      },
      allow_duplicate: this.state.optForRedonation,
    };
  }

  async onSuccess(data) {
    ee.emit('fundraiser:transaction_success', data, this.props.formData);
    return data;
  }

  async onFailure(reason) {
    this.setState({
      submitting: false,
      openPopup: reason.responseJSON
        ? reason.responseJSON.immediate_redonation
        : false,
      failureReason: reason.responseJSON.message,
      optForRedonation:
        reason.responseJSON && reason.responseJSON.immediate_redonation
          ? reason.responseJSON.immediate_redonation
          : false,
    });
    this.props.setSubmitting(false);
    ee.emit('fundraiser:transaction_error', reason, this.props.formData);
    return reason;
  }

  clearRecurringEvent() {
    ee.removeListener('fundraiser:change_recurring', this.submit, this);
  }

  onClickHandle(e) {
    const isRecurring = e.currentTarget.name === 'recurring';
    this.props.setRecurring(isRecurring);
    ee.on('fundraiser:change_recurring', this.submit, this);
  }

  submit() {
    const data = this.oneClickData();
    console.log('recurringDonar', this.state.recurringDonar);

    if (data) {
      if (data.allow_duplicate == false) delete data.allow_duplicate;
      ee.emit(
        'fundraiser:transaction_submitted',
        data.payment,
        this.props.formData
      );
      this.setState({ submitting: true });
      this.props.setSubmitting(true);
      $.post(
        `/api/payment/braintree/pages/${this.props.page.id}/one_click`,
        data
      ).then(this.onSuccess.bind(this), this.onFailure.bind(this));
    }
    this.clearRecurringEvent();
  }

  selectPaymentMethod(paymentMethod) {
    this.setState({ currentPaymentMethod: paymentMethod });
  }

  renderPaymentMethodRadio(paymentMethod) {
    return (
      <div className="ExpressDonation__payment-method-radio">
        <input
          type="radio"
          checked={this.state.currentPaymentMethod === paymentMethod}
          onChange={() => this.selectPaymentMethod(paymentMethod)}
        />
        <PaymentMethodItem paymentMethod={paymentMethod} />
      </div>
    );
  }

  renderSingle() {
    const item = this.state.currentPaymentMethod;
    if (!item) return null;
    return (
      <PaymentMethodWrapper>
        <div className="ExpressDonation__single-item">
          <PaymentMethodItem paymentMethod={item} />
        </div>
      </PaymentMethodWrapper>
    );
  }

  renderChoices() {
    return (
      <PaymentMethodWrapper>
        <span className="ExpressDonation__prompt">
          <FormattedMessage
            id="fundraiser.oneclick.select_payment"
            defaultMessage="Select a saved payment method"
          />
        </span>

        {this.props.paymentMethods.map(paymentMethod => (
          <PaymentMethodItem
            key={paymentMethod.id}
            paymentMethod={paymentMethod}
            checked={this.state.currentPaymentMethod === paymentMethod}
            onChange={() => this.selectPaymentMethod(paymentMethod)}
          />
        ))}
      </PaymentMethodWrapper>
    );
  }

  componentDidMount() {
    this.setState({
      akid: this.props.data.akid,
      source: this.props.data.source,
      recurringDefault: this.props.data.recurringDefault,
      onlyRecurring: this.props.data.onlyRecurring,
      recurringDonor: this.props.data.recurringDonor,
    });
  }

  render() {
    if (!this.props.paymentMethods.length || this.props.hidden) return null;

    return (
      <div className="ExpressDonation">
        <div className="ExpressDonation__payment-methods">
          {this.props.paymentMethods.length === 1
            ? this.renderSingle()
            : this.renderChoices()}
          <a
            className="ExpressDonation__toggle"
            onClick={() => this.props.onHide()}
          >
            <FormattedMessage
              id="fundraiser.oneclick.new_payment_method"
              defaultMessage="Add payment method"
            />
          </a>
        </div>

        {/* <Checkbox
          className="ExpressDonation__recurring-checkbox"
          disabled={this.props.fundraiser.recurringDefault === 'only_recurring'}
          checked={this.props.fundraiser.recurring}
          onChange={e => this.props.setRecurring(e.currentTarget.checked)}
        >
          <FormattedMessage
            id="fundraiser.make_recurring"
            defaultMessage="Make my donation monthly"
          />
        </Checkbox> */}

        <div className="payment-message">
          <br />
          {this.props.showMonthlyButton() && (
            <FormattedMessage
              id={'fundraiser.make_monthly_donation'}
              defaultMessage={`{name} a monthly donation will support our movement to plan ahead, so we can more effectively take on the biggest corporations that threaten people and planet.`}
              values={{
                name: this.getMemberName(
                  this.props.member,
                  this.props.formData
                ),
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
                    amount={this.props.fundraiser.donationAmount || 0}
                    currency={this.props.fundraiser.currency}
                  />
                ),
              }}
            />
          </div>

          {/* {!this.state.recurringDonor && (
            <div className="PaymentMethod__complete-donation donation-amount-text-2x">
              <FormattedMessage
                id={'fundraiser.donate_amount'}
                defaultMessage={`Donate {amount}`}
                className=""
                values={{
                  amount: (
                    <CurrencyAmount
                      amount={this.props.fundraiser.donationAmount || 0}
                      currency={this.props.fundraiser.currency}
                    />
                  ),
                }}
              />
            </div>
          )} */}
        </div>
        <>
          <ShowIf condition={this.props.showMonthlyButton()}>
            <DonateButton
              currency={this.props.fundraiser.currency}
              amount={this.props.fundraiser.donationAmount || 0}
              recurring={true}
              name="recurring"
              recurringDonor={this.state.recurringDonor}
              submitting={this.state.submitting}
              disabled={
                !this.state.currentPaymentMethod || this.state.submitting
              }
              onClick={e => this.onClickHandle(e)}
            />
          </ShowIf>

          <ShowIf condition={this.props.howOneOffButton()}>
            <DonateButton
              currency={this.props.fundraiser.currency}
              amount={this.props.fundraiser.donationAmount || 0}
              name="one_time"
              recurring={false}
              submitting={this.state.submitting}
              recurringDonor={this.state.recurringDonor}
              disabled={
                !this.state.currentPaymentMethod || this.state.submitting
              }
              onClick={e => this.onClickHandle(e)}
            />
          </ShowIf>
        </>

        <Popup
          open={this.state.openPopup}
          closeOnDocumentClick
          contentStyle={style}
          onClose={() => {
            this.setState({
              optForRedonation: false,
              openPopup: false,
            });
          }}
        >
          <div className="PaymentExpressDonationConflict">
            <div className="PaymentExpressDonationConflict--reason">
              {this.state.failureReason}
            </div>
            <Button
              className="PaymentExpressDonationConflict--accept"
              onClick={() => this.submit()}
            >
              <FormattedMessage
                id="consent.existing.accept"
                defaultMessage="Yes"
              />
            </Button>
            <Button
              className="PaymentExpressDonationConflict--decline"
              onClick={() => {
                this.setState({
                  optForRedonation: false,
                  openPopup: false,
                });
              }}
            >
              <FormattedMessage
                id="consent.existing.decline"
                defaultMessage="Not right now"
              />
            </Button>
          </div>
        </Popup>
      </div>
    );
  }
}

const mapStateToProps = state => ({
  paymentMethods: state.paymentMethods,
  fundraiser: state.fundraiser,
  page: state.page,
  formData: {
    storeInVault: state.fundraiser.storeInVault,
    member: {
      ...state.fundraiser.formValues,
      ...state.fundraiser.form,
    },
  },
});

const mapDispatchToProps = dispatch => ({
  setRecurring: value => dispatch(setRecurring(value)),
});

export default connect(mapStateToProps, mapDispatchToProps)(ExpressDonation);
