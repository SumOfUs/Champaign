// @flow
import $ from 'jquery';
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage, FormattedHTMLMessage } from 'react-intl';
import ee from '../../shared/pub_sub';
import Checkbox from '../Checkbox/Checkbox';
import DonateButton from '../DonateButton';
import PaymentMethodWrapper from './PaymentMethodWrapper';
import PaymentMethodItem from './PaymentMethod';
import { setRecurring } from '../../state/fundraiser/actions';

import type { Dispatch } from 'redux';
import type { AppState, PaymentMethod, Fundraiser } from '../../state';
import type { ChampaignPage } from '../../types';
import Popup from 'reactjs-popup';
import Button from '../../components/Button/Button';

import './ExpressDonation.scss';

const style = {
  width: 'auto',
  padding: 30,
};

type Props = {
  hidden: boolean,
  onHide: () => void,
  setSubmitting: boolean => void,
  paymentMethods: PaymentMethod[],
  fundraiser: Fundraiser,
  page: ChampaignPage,
  formData: {
    storeInVault: boolean,
    member: any,
  },
  setRecurring: boolean => void,
};

type State = {
  currentPaymentMethod: ?PaymentMethod,
  submitting: boolean,
  openPopup: boolean,
  opt_for_redonation: boolean,
  failureReason: string,
};

export class ExpressDonation extends Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      currentPaymentMethod: props.paymentMethods
        ? props.paymentMethods[0]
        : null,
      submitting: false,
      openPopup: false,
      opt_for_redonation: false,
      failureReason: '',
    };
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
      allow_duplicate: this.state.opt_for_redonation,
    };
  }

  async onSuccess(data: any): any {
    ee.emit('fundraiser:transaction_success', data, this.props.formData);
    return data;
  }

  async onFailure(reason: any): any {
    reason.responseJSON && reason.responseJSON.immediate_redonation
      ? (this.state.opt_for_redonation =
          reason.responseJSON.immediate_redonation)
      : null;
    this.setState({
      submitting: false,
      openPopup: reason.responseJSON
        ? reason.responseJSON.immediate_redonation
        : false,
      failureReason: reason.responseJSON.message,
    });
    this.props.setSubmitting(false);
    ee.emit('fundraiser:transaction_error', reason, this.props.formData);
    return reason;
  }

  submit() {
    const data = this.oneClickData();

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
  }

  selectPaymentMethod(paymentMethod: PaymentMethod) {
    this.setState({ currentPaymentMethod: paymentMethod });
  }

  renderPaymentMethodRadio(paymentMethod: PaymentMethod) {
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

        <Checkbox
          className="ExpressDonation__recurring-checkbox"
          disabled={this.props.fundraiser.recurringDefault === 'only_recurring'}
          checked={this.props.fundraiser.recurring}
          onChange={e => this.props.setRecurring(e.currentTarget.checked)}
        >
          <FormattedMessage
            id="fundraiser.make_recurring"
            defaultMessage="Make my donation monthly"
          />
        </Checkbox>

        <DonateButton
          currency={this.props.fundraiser.currency}
          amount={this.props.fundraiser.donationAmount || 0}
          recurring={this.props.fundraiser.recurring}
          submitting={this.state.submitting}
          disabled={!this.state.currentPaymentMethod || this.state.submitting}
          onClick={() => this.submit()}
        />
        <Popup
          open={this.state.openPopup}
          closeOnDocumentClick
          contentStyle={style}
          onClose={() => {
            this.setState({
              opt_for_redonation: false,
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
                  opt_for_redonation: false,
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

const mapStateToProps = (state: AppState) => ({
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

const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  setRecurring: (value: boolean) => dispatch(setRecurring(value)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ExpressDonation);
