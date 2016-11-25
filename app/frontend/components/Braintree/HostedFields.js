// @flow
import React, { Component } from 'react';
import braintree from 'braintree-web';
import './HostedFields.css';

export default class HostedFields extends Component {
  state: {
    clientInstance: any;
    hostedFields: any;
  };

  componentDidMount() {
    braintree.client.create({
      // this key is from their example docs so it's kinda public
      // so no worries here:
      authorization: 'sandbox_g42y39zw_348pk9cgf3bgyw2b',
      recurring: false,
    }, (err, instance) => {
      if (err) {
        console.log('braintree.client.create:', err);
        return null;
      }

      this.setState({ clientInstance: instance }, () => this.createHostedFields());
    });
  }

  createHostedFields() {
    braintree.hostedFields.create({
      client: this.state.clientInstance,
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
          placeholder: '4111 1111 1111 1111'
        },
        cvv: {
          selector: '#cvv',
          placeholder: '123'
        },
        expirationDate: {
          selector: '#expiration-date',
          placeholder: 'MM/YYYY'
        },
        postalCode: {
          selector: '#postal-code',
          placeholder: '11111'
        }
      }
    }, (err, hostedFieldsInstance) => {
      this.setState({ hostedFields: hostedFieldsInstance });
    });
  }

  teardown(event: SyntheticEvent) {
    event.preventDefault();

    if (!this.state.hostedFields) return null;
    console.log('teardown...');
    console.log('Submit your nonce to your server here!');
    console.log('clientInstance:', this.state.clientInstance.toJSON());
    console.log('hostedFields:', this.state.hostedFields.getState());
    this.state.hostedFields.teardown(this.afterTeardown.bind(this));
  }

  afterTeardown() {
    this.createHostedFields();
    this.setState({ hostedFields: null });
  }

  render() {
    return (
      <div className="HostedFields-root">
        <form method="post" id="cardForm" onSubmit={this.teardown.bind(this)}>
          <label className="hosted-fields--label" htmlFor="card-number">Card Number</label>
          <div id="card-number" className="hosted-field"></div>

          <label className="hosted-fields--label" htmlFor="expiration-date">Expiration Date</label>
          <div id="expiration-date" className="hosted-field"></div>

          <label className="hosted-fields--label" htmlFor="cvv">CVV</label>
          <div id="cvv" className="hosted-field"></div>

          <label className="hosted-fields--label" htmlFor="postal-code">Postal Code</label>
          <div id="postal-code" className="hosted-field"></div>

          <div className="button-container">
          <input type="submit" className="button button--small button--green" value="Purchase" id="submit"/>
          </div>
        </form>
      </div>
    );
  }
}
