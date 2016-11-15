// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedNumber, injectIntl } from 'react-intl';
import StepContent from '../../components/Stepper/StepContent';
import StepWrapper from '../../components/Stepper/StepWrapper';
import AmountSelection from '../../components/AmountSelection/AmountSelection';
import MemberDetailsForm from '../../components/MemberDetailsForm/MemberDetailsForm';
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
  donationAmount: ?number;
  changeStep: (step: number) => void;
  selectAmount: (amount: ?number) => void;
  selectCurrency: (currency: string) => void;
  submitDetails: (payload: any) => void;
  submitPayment: (payload: any) => void;
  intl: any;
};

type OwnState = {
  currencyDropdownVisible: boolean;
};

export class FundraiserView extends Component {
  props: OwnProps;
  state: OwnState;

  static defaultProps = {
    currentStep: 0,
    member: null,
    currency: 'USD',
    currencies: ['USD'],
    donationBands: [2, 5, 10, 25, 50],
  }

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      currentStep: 0,
      currencyDropdownVisible: false,
    };
  }

  selectAmount(amount: ?number) {
    this.props.selectAmount(amount);
    this.props.changeStep(this.props.currentStep + 1);
  }

  submitDetails(payload: any) {
    this.props.submitPayment(payload);
  }

  submitPayment(payload: any) {
    this.props.submitPayment(payload);
  }

  render() {
    const { member, donationAmount, currentStep } = this.props;
    const amountTitle = donationAmount ?
      <FormattedNumber
        value={this.props.donationAmount}
        style="currency"
        currency={this.props.currency}
        minimumFractionDigits={0}
        maximumFractionDigits={0} /> : 'amount';

    return (
      <div id="fundraiser-view" className="FundraiserView-container">
        <section className="FundraierView-steps section darken-background">
          <h2 className="FundraiserView-title title">
            Donate now
          </h2>
        </section>

        <StepWrapper currentStep={currentStep} changeStep={this.props.changeStep}>
          <StepContent title={amountTitle}>
            <AmountSelection
              donationAmount={this.props.donationAmount}
              donationBands={this.props.donationBands}
              currency={this.props.currency}
              currencies={this.props.currencies}
              onSelectAmount={amount => this.selectAmount(amount)}
              onChangeCurrency={this.props.selectCurrency.bind(this)}
              customAmount={10}
            />
          </StepContent>

          { !member &&
            <StepContent title="details">
              <MemberDetailsForm />
            </StepContent> }

          <StepContent title="payment">
            <div>PAYMENT FORM</div>
          </StepContent>
        </StepWrapper>

      </div>
    );
  }
}

export const mapStateToProps = (state: AppState) => ({
  member: state.member,
  amount: state.fundraiser.amount,
  currency: state.fundraiser.currency,
  currencies: state.fundraiser.currencies,
  currentStep: state.fundraiser.currentStep,
  donationBands: state.fundraiser.donationBands,
  donationAmount: state.fundraiser.donationAmount,
  recurring: state.fundraiser.recurring,
  storeInVault: state.fundraiser.storeInVault,
});

export const mapDispatchToProps = (dispatch: Dispatch) => ({
  changeStep: (step: number) => dispatch(changeStep(step)),
  selectAmount: (amount: ?number) => dispatch(changeAmount(amount)),
  selectCurrency: (currency: string) => dispatch(changeCurrency(currency)),
  submitDetails: (payload: any) => dispatch(submitDetails(payload)),
  submitPayment: (payload: any) => dispatch(submitPayment(payload)),
});

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(FundraiserView));
