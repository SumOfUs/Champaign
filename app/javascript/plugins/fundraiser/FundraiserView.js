import React, { Component, Fragment } from 'react';
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
import { localCurrencies } from './utils';
import unintendedDonationsExperiment from '../../experiments/unintended-donations';
import { setExperimentVariant } from '../../state/experiments';
import { resetMember } from '../../state/member/reducer';
import {
  changeAmount,
  changeCurrency,
  changeStep,
  setSelectedAmountButton,
  setSubmitting,
  setSupportedLocalCurrency,
  setIsCustomAmount,
} from '../../state/fundraiser/actions';

export class FundraiserView extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isLoaded: false,
    };
  }

  async componentDidMount() {
    if (window.dataLayer) {
      await window.dataLayer.push({
        event: unintendedDonationsExperiment.activationEvent,
      });
    }
    this.intervalId = setInterval(() => {
      if (window.google_optimize !== undefined) {
        const variant = window.google_optimize.get(
          unintendedDonationsExperiment.experimentId
        );

        if (variant) {
          this.props.setExperimentVariant({
            variant,
            experimentId: unintendedDonationsExperiment.experimentId,
          });
        }
        clearInterval(this.intervalId);
        this.setState({
          isLoaded: true,
        });
      } else {
        this.setState({
          isLoaded: true,
        });
      }
    }, 500);

    const { donationAmount } = this.props.fundraiser;
    this.props.setSupportedLocalCurrency(this.supportedLocalCurrency());
    if (donationAmount && donationAmount > 0) {
      this.props.selectAmount(donationAmount);
      this.props.changeStep(1);
    }
  }

  componentDidUpdate(prevProps) {
    if (
      prevProps.experiments.length == 0 &&
      this.props.experiments.length > 0
    ) {
      const { variant } =
        this.props.experiments.find(
          e => (e.experimentId = unintendedDonationsExperiment.experimentId)
        ) || {};

      if (variant && variant === '1' && this.props.idMismatch) {
        this.props.resetMember();
        this.props.changeStep(0);
      }
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

  supportedLocalCurrency() {
    const country = window.champaign.personalization.member.country;
    // Member is in a country where we are not concerned of confusion in currencies when we display the currency sign
    // - this is currently any country outside of Lat Am
    if (!Object.keys(localCurrencies).includes(country)) return true;
    return localCurrencies[country] === this.props.fundraiser.currency;
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
        supportedLocalCurrency,
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

    const supportedCurrencyDisclaimer = !supportedLocalCurrency ? (
      <div className="currency-disclaimer fundraiser-bar">
        <FormattedMessage
          id="fundraiser.currency_disclaimer"
          defaultMessage="Hello! We're working hard to soon be able to accept donations in your local currency. Meanwhile, we appreciate your patience — your donation will be processed in the foreign currency you select. Please note that your credit card might impose fees which SumOfUs has no control of. We truly appreciate your understanding."
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
      <Fragment>
        {this.state.isLoaded ? (
          <div id="fundraiser-view" className={classNames}>
            <StepWrapper
              title={this.props.fundraiser.title}
              submitting={submitting}
              currentStep={currentStep}
              changeStep={this.props.changeStep}
            >
              <StepContent
                title={AmountSelection.title(donationAmount, currency)}
              >
                <div>
                  {oneClickErrorMessage}
                  {supportedCurrencyDisclaimer}
                  <AmountSelection
                    donationAmount={donationAmount}
                    currency={currency}
                    donationBands={donationBands}
                    donationFeaturedAmount={donationFeaturedAmount}
                    nextStepTitle={firstStepButtonTitle}
                    changeCurrency={this.props.selectCurrency.bind(this)}
                    selectAmount={amount => this.selectAmount(amount)}
                    setSelectedAmountButton={this.props.setSelectedAmountButton.bind(
                      this
                    )}
                    proceed={this.proceed.bind(this)}
                    setIsCustomAmount={this.props.setIsCustomAmount.bind(this)}
                  />
                </div>
              </StepContent>

              {this.showStepTwo() && (
                <StepContent
                  title={<FormattedMessage id="fundraiser.details" />}
                >
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
        ) : null}
      </Fragment>
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
  supportedLocalCurrency: state.fundraiser.supportedLocalCurrency,
  experiments: state.abTests.experiments,
  idMismatch: state.fundraiser.id_mismatch,
});

export const mapDispatchToProps = dispatch => ({
  resetMember: () => dispatch(resetMember()),
  changeStep: step => dispatch(changeStep(step)),
  selectAmount: amount => dispatch(changeAmount(amount)),
  setSelectedAmountButton: selectedButton =>
    dispatch(setSelectedAmountButton(selectedButton)),
  selectCurrency: currency => dispatch(changeCurrency(currency)),
  setSubmitting: submitting => dispatch(setSubmitting(submitting)),
  setSupportedLocalCurrency: value =>
    dispatch(setSupportedLocalCurrency(value)),
  setExperimentVariant: value => dispatch(setExperimentVariant(value)),
  setIsCustomAmount: (isCustomAmount, amount) =>
    dispatch(setIsCustomAmount(isCustomAmount, amount)),
});

export default connect(mapStateToProps, mapDispatchToProps)(FundraiserView);
