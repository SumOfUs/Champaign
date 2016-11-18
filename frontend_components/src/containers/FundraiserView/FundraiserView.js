// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage, injectIntl } from 'react-intl';
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
        <section className="FundraierView-steps section darken-background">
          <h2 className="FundraiserView-title title">
            Donate now
          </h2>
        </section>

        <StepWrapper currentStep={currentStep} changeStep={this.props.changeStep}>
          <StepContent title={AmountSelection.title(donationAmount, currency)}>
            <AmountSelection
              donationAmount={donationAmount}
              currency={currency}
              donationBands={this.props.donationBands}
              currencies={this.props.currencies}
              nextStepTitle={ member ? 'payment' : MemberDetailsForm.title }
              changeCurrency={this.props.selectCurrency.bind(this)}
              selectAmount={amount => this.selectAmount(amount)}
              proceed={this.proceed.bind(this)}
            />
          </StepContent>

          { !member &&
            <StepContent title="details">
              <MemberDetailsForm
                buttonText={<FormattedMessage
                  id="proceed_to_x"
                  defaultMessage="Proceed to {name}"
                  values={{name: Payment.title}} />}
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
