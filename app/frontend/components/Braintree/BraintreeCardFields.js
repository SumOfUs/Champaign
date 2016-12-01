// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import hostedFields from 'braintree-web/hosted-fields';
import type { HostedFieldsInstance } from 'braintree-web/hosted-fields';
import './Braintree.scss';

type OwnProps = {
  client: ?BraintreeClient;
  onClick: () => void;
  isActive: boolean;
};

export default class BraintreeCardFields extends Component {
  props: OwnProps;

  state: {
    hostedFields: ?HostedFieldsInstance;
  };

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      hostedFields: null,
    };
  }


  componentDidMount() {
    if(this.props.client) {
      this.createHostedFields(this.props.client);
    }
  }

  componentWillReceiveProps(newProps: OwnProps) {
    if (newProps.client) {
      this.createHostedFields(newProps.client);
    }
  }


  createHostedFields(client: BraintreeClient) {
    hostedFields.create({
      client,
      styles: {
        input: {
          'font-size': '16px',
          'font-family': 'courier, monospace',
          'font-weight': 'lighter',
          'color': '#ccc'
        },
        ':focus': {
          'color': 'black'
        },
        '.valid': {
          'color': '#8bdda8'
        }
      },
      fields: {
        number: {
          selector: '#card-number',
          placeholder: 'Credit card number'
        },
        cvv: {
          selector: '#cvv',
          placeholder: 'Security code'
        },
        expirationDate: {
          selector: '#expiration-date',
          placeholder: 'MM/YY'
        },
      }
    }, (err, hostedFieldsInstance) => {
      this.setState({ hostedFields: hostedFieldsInstance });
    });
  }

  teardown(event: SyntheticEvent) {
    event.preventDefault();

    if (!this.state.hostedFields) return null;
    console.log('teardown...');
  }

  afterTeardown() {
    this.createHostedFields();
    this.setState({ hostedFields: null });
  }

  revealHostedFields(value: boolean) {
  }

  render() {
    const classNames = classnames({
      'BraintreeCardFields--root': true,
      active: this.props.isActive,
    });

    return (
      <div className={classNames}>
        <button onClick={this.props.onClick}>
          <FormattedMessage
            id="credit_or_debit_card"
            defaultMessage="Credit or Debit Card"
          />
        </button>

        <div className="BraintreeCardFields--form-container">
          <form method="post" id="cardForm" onSubmit={this.teardown.bind(this)}>
            <label className="hosted-fields--label" htmlFor="card-number">Card Number</label>
            <div id="card-number" className="hosted-field"></div>

            <label className="hosted-fields--label" htmlFor="expiration-date">Expiration Date</label>
            <div id="expiration-date" className="hosted-field"></div>

            <label className="hosted-fields--label" htmlFor="cvv">CVV</label>
            <div id="cvv" className="hosted-field"></div>

            <div className="button-container">
            <input type="submit" className="button button--small button--green" value="Purchase" id="submit"/>
            </div>
          </form>
        </div>
      </div>
    );
  }
}
