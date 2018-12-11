// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import _ from 'lodash';
import StepContent from '../components/Stepper/StepContent';
import StepWrapper from '../components/Stepper/StepWrapper';
import AmountSelection from '../components/AmountSelection/AmountSelection';
import MemberDetailsForm from '../components/MemberDetailsForm/MemberDetailsForm';
import Payment from '../components/Payment/Payment';
import OneClick from '../components/OneClick/OneClick';
import {
  changeAmount,
  changeCurrency,
  changeStep,
  setSubmitting,
} from '../state/fundraiser/actions';

import type { Dispatch } from 'redux';
import type { AppState } from '../state';
import type { Member, Fundraiser } from '../state';
import type { ChampaignPage } from '../types';

type Props = $Call<typeof mapStateToProps, AppState> &
  $Call<typeof mapDispatchToProps, *>;

export class FundraiserView extends Component<Props> {
  componentDidMount() {
    const { donationAmount } = this.props.fundraiser;

    if (donationAmount && donationAmount > 0) {
      this.props.selectAmount(donationAmount);
      this.props.changeStep(1);
    }
  }

  selectAmount(amount: ?number) {
    this.props.selectAmount(amount);

    if (typeof window.fbq === 'function') {
      window.fbq('track', 'InitiateCheckout', {
        value: this.props.fundraiser.donationAmount,
        currency: this.props.fundraiser.currency,
        content_name: this.props.page.title,
        content_ids: [this.props.page.id],
        content_type: 'product',
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
      'fundraiser-bar--freestanding': this.props.fundraiser.freestanding,
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

export const mapStateToProps = (state: AppState) => ({
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

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeStep: (step: number) => dispatch(changeStep(step)),
  selectAmount: (amount: ?number) => dispatch(changeAmount(amount)),
  selectCurrency: (currency: string) => dispatch(changeCurrency(currency)),
  setSubmitting: (submitting: boolean) => dispatch(setSubmitting(submitting)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(FundraiserView);
