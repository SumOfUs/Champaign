// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import StepContent from '../../components/Stepper/StepContent';
import StepWrapper from '../../components/Stepper/StepWrapper';
import AmountSelection from '../../components/AmountSelection/AmountSelection';
import MemberDetailsForm from '../../components/MemberDetailsForm/MemberDetailsForm';
import Payment from '../../components/Payment/Payment';
import {
  changeAmount,
  changeCurrency,
  changeStep,
  submitDetails,
  submitPayment,
} from '../../state/fundraiser/actions';

type OwnProps = {
  currentStep: number;
  member: MemberState;
  currency: string;
  currencies: string[];
  donationBands: number[];
  donationFeaturedAmount: ?number;
  donationAmount: ?number;
  changeStep: (step: number) => void;
  selectAmount: (amount: ?number) => void;
  selectCurrency: (currency: string) => void;
  submitDetails: (payload: any) => void;
  submitPayment: (payload: any) => void;
  fields: any[];
  outstandingFields: Object;
  formId: number;
};

export class FundraiserView extends Component {
  props: OwnProps & mapStateToProps;

  static defaultProps = {
    currentStep: 0,
    member: null,
    currency: 'USD',
    currencies: ['USD'],
    donationBands: [2, 5, 10, 25, 50],
  }

  selectAmount(amount: ?number) {
    this.props.selectAmount(amount);
  }

  proceed() {
    this.props.changeStep(this.props.currentStep + 1);
  }

  submitDetails(payload: any) {
    this.props.submitPayment(payload);
  }

  submitPayment(payload: any) {
    this.props.submitPayment(payload);
  }

  render() {
    const { member, donationAmount, currency, currentStep } = this.props;

    return (
      <div id="fundraiser-view" className="FundraiserView-container">
        <StepWrapper title={this.props.title} currentStep={currentStep} changeStep={this.props.changeStep}>
          <StepContent title={AmountSelection.title(donationAmount, currency)}>
            <AmountSelection
              donationAmount={donationAmount}
              currency={currency}
              donationBands={this.props.donationBands}
              donationFeaturedAmount={this.props.donationFeaturedAmount}
              currencies={this.props.currencies}
              nextStepTitle={ member ? 'payment' : MemberDetailsForm.title }
              changeCurrency={this.props.selectCurrency.bind(this)}
              selectAmount={amount => this.selectAmount(amount)}
              proceed={this.proceed.bind(this)}
            />
          </StepContent>

          { this.props.outstandingFields !== [] &&
            <StepContent title="details">
              <MemberDetailsForm
                buttonText={I18n.t('fundraiser.proceed_to_payment')}
                fields={this.props.fields}
                outstandingFields={this.props.outstandingFields}
                prefillValues={this.props.member}
                formId={this.props.formId}
                proceed={this.proceed.bind(this)}
              />
            </StepContent> }

          <StepContent title="payment">
            <Payment />
          </StepContent>
        </StepWrapper>
      </div>
    );
  }
}

export const mapStateToProps = (state: AppState) => ({
  member: state.member,
  amount: state.fundraiser.amount,
  title: state.fundraiser.title,
  currency: state.fundraiser.currency,
  currencies: state.fundraiser.currencies,
  currentStep: state.fundraiser.currentStep,
  donationBands: state.fundraiser.donationBands,
  donationAmount: state.fundraiser.donationAmount,
  recurring: state.fundraiser.recurring,
  fields: state.fundraiser.fields,
  outstandingFields: state.fundraiser.outstandingFields,
  formId: state.fundraiser.formId,
  storeInVault: state.fundraiser.storeInVault,
});

export const mapDispatchToProps = (dispatch: Dispatch) => ({
  changeStep: (step: number) => dispatch(changeStep(step)),
  selectAmount: (amount: ?number) => dispatch(changeAmount(amount)),
  selectCurrency: (currency: string) => dispatch(changeCurrency(currency)),
  submitDetails: (payload: any) => dispatch(submitDetails(payload)),
  submitPayment: (payload: any) => dispatch(submitPayment(payload)),
});

export default connect(mapStateToProps, mapDispatchToProps)(FundraiserView);
