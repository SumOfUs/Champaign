import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import _ from 'lodash';
import StepContent from '../../components/Stepper/StepContent';
import StepWrapper from '../../components/Stepper/StepWrapper';
import AmountSelection from '../../components/AmountSelection/AmountSelection';
import MemberDetailsForm from '../../components/MemberDetailsForm/MemberDetailsForm';
import Payment from '../../components/Payment/Payment';
import OneClick from '../../components/OneClick/OneClick';
import Cookie from 'js-cookie';

import {
  changeAmount,
  changeCurrency,
  changeStep,
  setSubmitting,
} from '../../state/fundraiser/actions';

export class FundraiserView extends Component {
  componentDidMount() {
    const { donationAmount } = this.props.fundraiser;
    if (donationAmount && donationAmount > 0) {
      this.props.selectAmount(donationAmount);
      this.props.changeStep(1);
    }
  }

  selectAmount(amount) {
    this.props.selectAmount(amount);
    const userId =
      window.champaign.personalization.member.id || Cookie.get('__bpmx');
    if (typeof window.fbq === 'function') {
      window.fbq('track', 'InitiateCheckout', {
        value: amount,
        currency: this.props.fundraiser.currency,
        content_name: this.props.page.title,
        content_ids: [this.props.page.id],
        content_type: 'product',
        user_id: userId,
        product_catalog_id: 445876772724152,
        page_id: this.props.page.id,
      });
    }
  }

  proceed() {
    this.props.changeStep(this.props.fundraiser.currentStep + 1);
  }

  showStepTwo() {
    const { outstandingFields } = this.props.fundraiser;
    return !outstandingFields || outstandingFields.length !== 0;
  }

  render() {
    const {
      fundraiser: {
        formId,
        fields,
        formValues,
        donationBands,
        donationAmount,
        donationFeaturedAmount,
        currency,
        currentStep,
        outstandingFields,
        submitting,
        oneClickError,
      },
    } = this.props;

    // todo move this into AmountSelection (connect it to store)
    const firstStepButtonTitle = _.isEmpty(formValues) ? (
      <FormattedMessage
        id="fundraiser.proceed_to_details"
        defaultMessage="Proceed to details (default)"
      />
    ) : (
      <FormattedMessage
        id="fundraiser.proceed_to_payment"
        defaultMessage="Proceed to payment (default)"
      />
    );

    const classNames = classnames({
      'FundraiserView-container': true,
      'form--big': true,
    });

    const oneClickErrorMessage = oneClickError ? (
      <div className="fundraiser-bar__errors">
        <FormattedMessage
          id="fundraiser.one_click_failed"
          defaultMessage="We're sorry but we could not process your donation. Please try again with a different card"
        />
      </div>
    ) : null;

    if (this.props.oneClickDonate) {
      return (
        <div id="fundraiser-view" className={classNames}>
          <OneClick />
        </div>
      );
    }

    return (
      <div id="fundraiser-view" className={classNames}>
        <StepWrapper
          title={this.props.fundraiser.title}
          submitting={submitting}
          currentStep={currentStep}
          changeStep={this.props.changeStep}
        >
          <StepContent title={AmountSelection.title(donationAmount, currency)}>
            <div>
              {oneClickErrorMessage}
              <AmountSelection
                donationAmount={donationAmount}
                currency={currency}
                donationBands={donationBands}
                donationFeaturedAmount={donationFeaturedAmount}
                nextStepTitle={firstStepButtonTitle}
                changeCurrency={this.props.selectCurrency.bind(this)}
                selectAmount={amount => this.selectAmount(amount)}
                proceed={this.proceed.bind(this)}
              />
            </div>
          </StepContent>

          {this.showStepTwo() && (
            <StepContent title={<FormattedMessage id="fundraiser.details" />}>
              <MemberDetailsForm
                buttonText={
                  <FormattedMessage
                    id="fundraiser.proceed_to_payment"
                    defaultMessage="Proceed to payment"
                  />
                }
                fields={fields}
                outstandingFields={outstandingFields}
                formValues={formValues}
                formId={formId}
                pageId={this.props.page.id}
                proceed={this.proceed.bind(this)}
              />
            </StepContent>
          )}

          <StepContent title={<FormattedMessage id="fundraiser.payment" />}>
            <Payment
              page={this.props.page}
              disableFormReveal={this.showStepTwo()}
              setSubmitting={s => this.props.setSubmitting(s)}
            />
          </StepContent>
        </StepWrapper>
      </div>
    );
  }
}

export const mapStateToProps = state => ({
  paymentMethods: state.paymentMethods,
  features: state.features,
  fundraiser: state.fundraiser,
  member: state.member,
  page: state.page,
  oneClickError: state.fundraiser.oneClickError,
  oneClickDonate:
    state.fundraiser.oneClick &&
    state.paymentMethods.length > 0 &&
    !state.fundraiser.disableSavedPayments,
});

export const mapDispatchToProps = dispatch => ({
  changeStep: step => dispatch(changeStep(step)),
  selectAmount: amount => dispatch(changeAmount(amount)),
  selectCurrency: currency => dispatch(changeCurrency(currency)),
  setSubmitting: submitting => dispatch(setSubmitting(submitting)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(FundraiserView);
