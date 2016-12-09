// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import $ from 'jquery';
import { FormattedMessage } from 'react-intl';

import type {
  AppState,
  PaymentMethod,
  FundraiserState
} from '../../state';

import './ExpressDonation.scss';

type OwnProps = {
  fundraiser: FundraiserState;
  paymentMethods: PaymentMethod[];
};

type OwnState = { currentPaymentMethod: ?PaymentMethod };

const mapStateToProps = (state: AppState): OwnProps => ({
  paymentMethods: state.paymentMethods,
  fundraiser: state.fundraiser,
});

export class ExpressDonation extends Component {
  props: OwnProps;
  state: OwnState;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      currentPaymentMethod: props.paymentMethods ? props.paymentMethods[0] : null,
    };
  }

  componentWillReceiveProps(newProps: OwnProps) {
    this.setState({ currentPaymentMethod: newProps.paymentMethods[0] });
  }

  async onSuccess(data: any) {
    console.log(data);
    return data;
  }

  async onFailure(reason: any) {
    console.log(reason);
    return reason;
  }

  submit() {
    const { fundraiser: { pageId } }  = this.props;
    return $.post(`/api/payment/braintree/pages/${pageId}/one_click`)
      .then(this.onSuccess.bind(this), this.onFailure.bind(this));
  }

  messageDescriptor(paymentMethod: PaymentMethod) {
    const type = paymentMethod.instrument_type;
    if (type === 'credit_card') {
      return {
        id: 'fundraiser.oneclick.credit_card_payment_method',
        defaultMessage: '{card_type} ending in {last_four_digits}',
        values: {
          card_type: paymentMethod.card_type,
          last_four_digits: paymentMethod.last_4,
        },
      };
    }

    if (type === 'paypal_account') {
      return {
        id: 'fundraiser.oneclick.paypal_payment_method',
        defaultMessage: 'PayPal ({email})',
        values: { email: paymentMethod.email },
      };
    }

    return {
      id: 'fundraiser.oneclick.payment_method',
      defaultMessage: 'Payment method'
    };
  }

  renderPaymentMethod(paymentMethod: PaymentMethod) {
    return (
      <div className="ExpressDonation__payment-method">
        <FormattedMessage {...this.messageDescriptor(paymentMethod)} />
      </div>
    );
  }

  renderSingle() {
    const item = this.state.currentPaymentMethod;
    if (!item) return null;
    return (
      <div className="ExpressDonation__payment-methods">
        <i className="ExpressDonation__icon fa fa-credit-card" />
        <div className="ExpressDonation__single-item">
          {this.renderPaymentMethod(item)}
        </div>
      </div>
    );
  }

  renderSelection() {
    return (
      <div className="ExpressDonation__payment-methods">
        <i className="ExpressDonation__icon fa fa-credit-card" />
        <span className="ExpressDonation__single-item">
          <FormattedMessage id="fundraiser.oneclick.select_payment" defaultMessage="Select a saved payment method" />
        </span>
      </div>
    );
  }

  renderPaymentMethods() {
    if (this.props.paymentMethods.length === 1) return this.renderSingle();

    return this.renderSelection();
  }

  render() {
    if (this.props.paymentMethods.length === 0) return null;

    return (
      <div className="ExpressDonation">
        { this.renderPaymentMethods() }
      </div>
    );
  }
}

export default connect(mapStateToProps)(ExpressDonation);
