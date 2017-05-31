// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import isEmpty from 'lodash/isEmpty';
import StepContent from '../components/Stepper/StepContent';
import StepWrapper from '../components/Stepper/StepWrapper';
import AmountSelection from '../components/AmountSelection/AmountSelection';
import MemberDetailsForm from '../components/MemberDetailsForm/MemberDetailsForm';
import Payment from '../components/Payment/Payment';
import {
  changeAmount,
  changeCurrency,
  changeStep,
  setSubmitting,
} from '../state/fundraiser/actions';

import type { Dispatch } from 'redux';
import type { AppState } from '../state';
import type { Member, Fundraiser, Page } from '../state';

type OwnProps = {
  fundraiser: Fundraiser;
  member: Member;
  page: Page;
  changeStep: (number) => any,
  selectAmount: (?number) => any,
  selectCurrency: (string) => any,
  setSubmitting: (boolean) => any,
};

export class FundraiserView extends Component {
  props: OwnProps;

  componentDidMount() {
    const { donationAmount } = this.props.fundraiser;

    if (donationAmount && donationAmount > 0) {
      this.props.selectAmount(donationAmount);
      this.props.changeStep(1);
    }
  }

  selectAmount(amount: ?number) {
    this.props.selectAmount(amount);
    fbq('track', 'InitiateCheckout', {
      value: this.props.fundraiser.donationAmount,
      currency: this.props.fundraiser.currency,
      content_name: this.props.page.title,
      content_ids: [this.props.page.id],
      content_type: 'product',
    });
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
      }
    }  = this.props;

    // todo move this into AmountSelection (connect it to store)
    const firstStepButtonTitle = isEmpty(formValues) ?
      <FormattedMessage id="fundraiser.proceed_to_details" defaultMessage="Proceed to details (default)" /> :
      <FormattedMessage id="fundraiser.proceed_to_payment" defaultMessage="Proceed to payment (default)" />;


    const classNames = classnames({
      "FundraiserView-container": true,
      "form--big": true,
      "fundraiser-bar--freestanding": this.props.fundraiser.freestanding
    });

    return (
      <div id="fundraiser-view" className={classNames}>
        <StepWrapper title={this.props.fundraiser.title}
                     submitting={submitting}
                     currentStep={currentStep} changeStep={this.props.changeStep}>
          <StepContent title={AmountSelection.title(donationAmount, currency)}>
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
          </StepContent>

          { this.showStepTwo() &&
            <StepContent title={<FormattedMessage id="fundraiser.details" />}>
              <MemberDetailsForm
                buttonText={<FormattedMessage id="fundraiser.proceed_to_payment" defaultMessage="Proceed to payment" />}
                fields={fields}
                outstandingFields={outstandingFields}
                prefillValues={formValues}
                formId={formId}
                pageId={this.props.page.id}
                proceed={this.proceed.bind(this)}
              />
            </StepContent>
          }

          <StepContent title={<FormattedMessage id="fundraiser.payment" />}>
            <Payment disableFormReveal={this.showStepTwo()} setSubmitting={s => this.props.setSubmitting(s)} />
          </StepContent>
        </StepWrapper>
      </div>
    );
  }
}

export const mapStateToProps = (state: AppState) => ({
  fundraiser: state.fundraiser,
  member: state.member,
  page: state.page,
});

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeStep: (step: number) => dispatch(changeStep(step)),
  selectAmount: (amount: ?number) => dispatch(changeAmount(amount)),
  selectCurrency: (currency: string) => dispatch(changeCurrency(currency)),
  setSubmitting: (submitting: boolean) => dispatch(setSubmitting(submitting)),
});

export default connect(mapStateToProps, mapDispatchToProps)(FundraiserView);
