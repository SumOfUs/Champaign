import React, { Component } from 'react';
import Button from '../Button/Button';
import HostedFields from '../Braintree/HostedFields';
import { FormattedMessage } from 'react-intl';
import './Payment.css';

export default class Payment extends Component {
  static title = <FormattedMessage id="payment" defaultMessage="payment" />;
  render() {
    return (
      <div className="Payment-root section">
        <Button>Hi</Button>
        <strong style={{textAlign: 'center', display: 'block', color: '#bbb'}}>OR</strong>
        <HostedFields />
      </div>
    );
  }
}
