import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { snakeCase } from 'lodash';
import DonationBands from '../DonationBands/DonationBands';
import DonateButton from '../DonateButton';
import CurrencySelector from '../CurrencySelector/CurrencySelector';
import ee from '../../shared/pub_sub';

import {
  changeAmount,
  setSubmitting,
  oneClickFailed,
} from '../../state/fundraiser/actions';

class OneClick extends Component {
  constructor(props) {
    super(props);
    this.state = {
      amountConfirmationRequired: false,
      submitting: false,
    };
  }

  async onSelectCustomAmount(amount) {
    await this.props.selectAmount(amount);
    this.setState({ amountConfirmationRequired: true });
  }

  async selectAmount(amount) {
    this.props.selectAmount(amount);
    this.submit();
  }

  oneClickData() {
    return {
      payment: {
        currency: this.props.currency,
        amount: this.props.donationAmount,
        recurring: false,
        payment_method_id: this.props.paymentMethods[0].id,
      },
      user: {
        form_id: this.props.formId,
        // formValues will have the prefillValues
        ...this.props.formValues,
        // form will have the user's submitted values
        ...this.props.form,
      },
    };
  }

  submit = () => {
    const data = this.oneClickData();
    if (data) {
      this.props.setSubmitting(true);

      $.post(
        `/api/payment/braintree/pages/${this.props.page.id}/one_click`,
        data
      ).then(this.onSuccess.bind(this), this.onFailure.bind(this));
    }
  };

  async onFailure(reason) {
    this.setState({ submitting: false });
    this.props.setSubmitting(false);
    this.props.oneClickFailed();

    ee.emit('fundraiser:transaction_error', reason, this.oneClickData());
    return reason;
  }

  async onSuccess(data) {
    ee.emit('fundraiser:transaction_success', data, this.oneClickData());
    const label = 'successful_one_time_donation_submitted';
    const event = 'fundraiser:one_time_transaction_submitted';

    ee.emit(event, label);

    const { original, forced } =
      window.champaign.plugins?.fundraiser?.default?.config?.fundraiser
        ?.forcedDonateLayout || {};
    const emitForcedLayoutSuccess = () => {
      ee.emit(`${event}_forced_layout`, {
        label: `${snakeCase(original)}_template_used_scroll_to_donate`,
        amount: this.props.donationAmount,
      });
    };

    if (forced === true) {
      emitForcedLayoutSuccess();
    }

    return data;
  }

  donateButton() {
    if (!this.state.amountConfirmationRequired) return null;
    if (!this.props.donationAmount) return null;

    return (
      <DonateButton
        currency={this.props.currency}
        amount={this.props.donationAmount || 0}
        recurring={false}
        submitting={this.state.submitting}
        disabled={this.state.submitting}
        onClick={() => this.submit()}
      />
    );
  }

  procssingView() {
    return (
      <div className="submission-interstitial">
        <h1 className="submission-interstitial__title">
          <i className="fa fa-spin fa-cog" />
          <FormattedMessage id="form.processing" />
        </h1>
        <h4>
          <FormattedMessage id="form.do_not_close" />
        </h4>
      </div>
    );
  }

  paymentOptionsView() {
    return (
      <div className="OneClick">
        <div className="StepWrapper-root">
          <div className="overlay-toggle__mobile-ui">
            <a className="overlay-toggle__close-button">✕</a>
          </div>
          <div className="Stepper fundraiser-bar__top">
            <h2 className="Stepper__header">{this.props.title}</h2>
          </div>
          <div className="fundraiser-bar__main">
            <p>
              <FormattedMessage
                id="fundraiser.one_click_warning"
                defaultMessage="Your donation will be processed immediately."
              />
            </p>

            <DonationBands
              amounts={this.props.donationBands[this.props.currency]}
              currency={this.props.currency}
              featuredAmount={this.props.donationFeaturedAmount}
              proceed={() => {}}
              selectAmount={this.selectAmount.bind(this)}
              selectCustomAmount={this.onSelectCustomAmount.bind(this)}
            />

            {this.donateButton()}
            <CurrencySelector />
          </div>
        </div>
      </div>
    );
  }

  render() {
    return this.props.submitting
      ? this.procssingView()
      : this.paymentOptionsView();
  }
}

const mapState = state => ({
  currency: state.fundraiser.currency,
  donationAmount: state.fundraiser.donationAmount,
  donationBands: state.fundraiser.donationBands,
  recurring: state.fundraiser.recurring,
  paymentMethods: state.paymentMethods,
  formId: state.fundraiser.formId,
  formValues: state.fundraiser.formValues,
  form: state.fundraiser.form,
  page: state.page,
  submitting: state.fundraiser.submitting,
  title: state.fundraiser.title,
  donationFeaturedAmount: state.fundraiser.donationFeaturedAmount,
});

const mapDispatch = dispatch => ({
  selectAmount: amount => dispatch(changeAmount(amount)),
  setSubmitting: submitting => dispatch(setSubmitting(submitting)),
  oneClickFailed: () => dispatch(oneClickFailed()),
});

export default connect(mapState, mapDispatch)(OneClick);
