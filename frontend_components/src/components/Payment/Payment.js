import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';

export default class Payment extends Component {
  static title = <FormattedMessage id="payment" defaultMessage="payment" />;
  render() {
    return <div>Payment</div>;
  }
}
