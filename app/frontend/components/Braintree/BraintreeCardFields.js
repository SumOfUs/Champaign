// @flow
import React, { Component } from 'react';
import { injectIntl } from 'react-intl';
import classnames from 'classnames';
import hostedFields from 'braintree-web/hosted-fields';
import type { HostedFieldsInstance, HostedFieldsTokenizePayload } from 'braintree-web/hosted-fields';
import './Braintree.scss';

type OwnProps = {
  client: ?BraintreeClient;
  isActive: boolean;
  recurring: boolean;
  intl: any;
  onInit?: () => void;
  onSuccess?: (data: any) => void;
  onFailure?: (data: any) => void;
};

class BraintreeCardFields extends Component {
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
    if (newProps.client !== this.props.client) {
      this.createHostedFields(newProps.client);
    }
  }

  componentWillUnmount() {
    if (this.state.hostedFields) {
      this.state.hostedFields.teardown();
    }
  }

  createHostedFields(client: BraintreeClient) {
    const formatMessage = this.props.intl.formatMessage;
    hostedFields.create({
      client,
      styles: {
        input: {
          color: '#ccc',
          'font-size': '16px',
        },
        ':focus': { color: '#333' },
        '.valid': { color: '#333' },
      },
      fields: {
        number: {
          selector: '#braintree-card-number',
          placeholder: formatMessage({ id: 'fundraiser.fields.number', defaultMessage: 'Card number' }),
        },
        cvv: {
          selector: '#braintree-cvv',
          placeholder: formatMessage({ id: 'fundraiser.fields.cvv', defaultMessage: 'CVV' }),
        },
        expirationDate: {
          selector: '#braintree-expiration-date',
          placeholder: formatMessage({ id: 'fundraiser.fields.expiration_format', defaultMessage: 'MM/YY' }),
        },
      }
    }, (err, hostedFieldsInstance) => {
      this.setState({ hostedFields: hostedFieldsInstance }, () => {
        if (this.props.onInit) {
          this.props.onInit();
        }
      });
    });
  }

  teardown() {
    console.log('teardown...');
    if (!this.state.hostedFields) return null;
    this.state.hostedFields.teardown(() => this.createHostedFields(this.props.client));
  }

  submit(event?: SyntheticEvent) {
    if (event) event.preventDefault();

    return new Promise((resolve, reject) => {
      if (!this.state.hostedFields) return reject();

      this.state.hostedFields.tokenize({
        vault: this.props.recurring,
      }, (error: ?BraintreeError, data: HostedFieldsTokenizePayload) => {
        if (error) return reject(error);
        this.teardown();
        resolve(data);
        console.log('success hosted fields:', data);
      });
    });
  }

  render() {
    const prefix = 'BraintreeCardFields';
    const classNames = classnames({
      [prefix]: true,
      [`${prefix}--active`]: this.props.isActive,
    });

    return (
      <div className={classNames}>
        <form
          id="braintree-hosted-fields-form"
          className="BraintreeCardFields__form"
          method="post"
          onSubmit={this.submit.bind(this)}>

          <div id="braintree-card-number" className="BraintreeCardFields__hosted-field BraintreeCardFields__card-number"></div>
          <div className="BraintreeCardFields__row">
            <div id="braintree-cvv" className="BraintreeCardFields__hosted-field BraintreeCardFields__cvv"></div>
            <div id="braintree-expiration-date" className="BraintreeCardFields__hosted-field BraintreeCardFields__expiration-date"></div>
          </div>

        </form>
      </div>
    );
  }
}

export default injectIntl(BraintreeCardFields, { withRef: true });
