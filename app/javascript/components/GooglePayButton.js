// @flow
import React, { Component } from 'react';
import googlePayment from 'braintree-web/google-payment';
import { connect } from 'react-redux';

import type { AppState, PaymentMethod } from '../state';

type Props = {
  client: ?any,
  onSubmit: (result: Object) => void,
} & typeof mapStateToProps;

type State = {
  paymentsClient?: Object,
  googlePaymentInstance?: Object,
  ready: boolean,
};

// TODO:
// Do with this as you please...
// Do we want to display google pay only on androids? Unlike Apple Pay,
// Google Pay not restricted to Android devices.
const isAndroid = navigator.userAgent.toLowerCase().indexOf('android') >= 0;

// GooglePayButton renders a Google Pay button. In order to do that, we need:
//   1. A Braintree client to be initialised
//   2. A Braintree Google Payments client to be initialised (with the braintree client)
//   3. Fetch pay.js from Google, and use that to create the Google Pay button.
// This component / class orchestrates the process.
// Note: One aspect of this that's not ideal is that this button component and
// its corresponding the "google" payment method option in the PaymentTypeSelection
// component are independent of each other, so if this button fails to initialise
// properly, the option might still be visible (but no button would be rendered). We
// could try to couple them but it would require communicating both components via
// the global state, or refactor the fundraising component to contain that state at
// the parent, or to "register" itself once it's "ready" (with a callback to the parent).
export class GooglePayButton extends Component {
  props: Props;
  state: State;
  buttonRef: any;
  constructor(props: Props) {
    super(props);
    // $FlowIgnore
    this.buttonRef = React.createRef();
    this.state = {
      paymentsClient: undefined,
      googlePaymentInstance: undefined,
      ready: false,
    };
  }

  // createGooglePayButton downloads the pay.js script from Google,
  // and if successful, creates a google payments client. That client is
  // then used to create a google pay button.
  createGooglePayButton = () => {
    $.ajax({
      url: 'https://pay.google.com/gp/p/js/pay.js',
      dataType: 'script',
    }).then(() => {
      if (window.google) {
        const paymentsClient = new window.google.payments.api.PaymentsClient({
          environment:
            process.env.NODE_ENV === 'production' ? 'PRODUCTION' : 'TEST',
        });

        const button = paymentsClient.createButton({
          onClick: this.onClick,
          buttonType: 'short',
        });
        this.buttonRef.current.appendChild(button);

        this.setState({ paymentsClient });
      }
    });
  };

  // setupGooglePay creates a *Braintree* google payment instance. This
  // is necessary since we're integrating through Braintree. It requires
  // a braintree client (passed down via props) and a google payments client
  // (to check `isReadyToPay` method)
  // Once the isReadyToPay promise resolves, we update state and set ready: true,
  // which enables this component.
  setupGooglePay() {
    const { client } = this.props;
    const { paymentsClient } = this.state;
    if (client && paymentsClient) {
      googlePayment.create({ client }, (err, googlePaymentInstance) => {
        paymentsClient
          .isReadyToPay({
            allowedPaymentMethods: googlePaymentInstance.createPaymentDataRequest()
              .allowedPaymentMethods,
          })
          .then(response => {
            if (response.result) {
              this.setState({
                paymentsClient,
                googlePaymentInstance,
                ready: true,
              });
            }
          });
      });
    }
  }

  componentDidMount() {
    this.createGooglePayButton();
    this.setupGooglePay();
  }

  componentDidUpdate(prevProps: Props, prevState: State) {
    if (
      prevProps.client !== this.props.client ||
      prevState.paymentsClient !== this.state.paymentsClient
    ) {
      this.setupGooglePay();
    }
  }

  onClick = (e: any) => {
    e.preventDefault();
    const { ready, googlePaymentInstance, paymentsClient } = this.state;
    if (ready && googlePaymentInstance && paymentsClient) {
      const paymentDataRequest = googlePaymentInstance.createPaymentDataRequest(
        {
          merchantId: undefined,
          transactionInfo: {
            currencyCode: this.props.currency,
            totalPrice: this.props.amount.toString(),
            totalPriceStatus: 'FINAL',
          },
          cardRequirements: {
            billingAddressRequired: true,
          },
        }
      );

      paymentsClient
        .loadPaymentData(paymentDataRequest)
        .then(paymentData => {
          googlePaymentInstance.parseResponse(paymentData, (err, result) => {
            if (err) {
              // TODO
              // Handle parsing error
            }
            this.props.onSubmit(result);
          });
        })
        .catch(function(err) {
          // TODO
          // Handle errors
        });
    }
  };

  render() {
    const style = {
      display: this.props.currentPaymentType === 'google' ? 'block' : 'none',
    };
    return <div ref={this.buttonRef} style={style} />;
  }
}

const mapStateToProps = (state: AppState) => ({
  currentPaymentType: state.fundraiser.currentPaymentType,
  fundraiser: state.fundraiser,
  currency: state.fundraiser.currency,
  amount: state.fundraiser.donationAmount,
});

export default connect(mapStateToProps)(GooglePayButton);
