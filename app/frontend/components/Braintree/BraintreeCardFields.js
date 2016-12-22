// @flow
import React, { Component } from 'react';
import { injectIntl, FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import hostedFields from 'braintree-web/hosted-fields';
import type { HostedFieldsInstance, HostedFieldsTokenizePayload } from 'braintree-web/hosted-fields';
import _ from 'lodash';
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
    cardType: '';
    errors: { [key:string]: boolean };
  };

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      hostedFields: null,
      errors: {
        number: false,
        expirationDate: false,
        cvv: false
      }
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
        }
      }
    }, (err, hostedFieldsInstance) => {
      this.setState({ hostedFields: hostedFieldsInstance }, () => {
        if (this.props.onInit) {
          this.props.onInit();
        }
      });

      hostedFieldsInstance.on('validityChange', (event) => {
        const field = event.fields[event.emittedBy];
        const newErrors = {};
        newErrors[event.emittedBy] = !field.isPotentiallyValid;
        this.setState({ errors: _.assign(this.state.errors, newErrors)});
      });

      hostedFieldsInstance.on('cardTypeChange', (event) => {
        if (event.cards.length === 1) {
          this.setState({ cardType: event.cards[0].type });
        } else {
          this.setState({ cardType: '' });
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
        console.log('Success BraintreeCardFields:', data);
      });
    });
  }

  currentCardClass(cardType: string) {
    const icons = {
      'diners-club': 'fa-cc-diners-club',
      'jcb': 'fa-cc-jcb',
      'american-express': 'fa-cc-amex',
      'discover': 'fa-cc-discover',
      'master-card': 'fa-cc-mastercard',
      'visa': 'fa-cc-visa',
    };
    return icons[cardType] || 'hidden-irrelevant';
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

          <div id="braintree-card-number" className="BraintreeCardFields__hosted-field BraintreeCardFields__card-number"> </div>
          <span ref="card_type" className={"BraintreeCardFields__card-type fa " + this.currentCardClass(this.state.cardType)}></span>
          { this.state.errors.number && this.renderError('number') }
          <div className="BraintreeCardFields__row clearfix">
            <div id="braintree-cvv" className="BraintreeCardFields__hosted-field BraintreeCardFields__cvv"></div>
            <div id="braintree-expiration-date" className="BraintreeCardFields__hosted-field BraintreeCardFields__expiration-date"></div>
          </div>
          { this.state.errors.cvv && this.renderError('cvv', "BraintreeCardFields__error-msg--col-left") }
          { this.state.errors.expirationDate && this.renderError('expiration', "BraintreeCardFields__error-msg--col-right") }

        </form>
      </div>
    );
  }

  renderError(field: string, className="") {
    return <div className={`BraintreeCardFields__error-msg error-msg ${className}`}>
      <FormattedMessage id={`fundraiser.field_names.${field}`} defaultMessage={`${field} (missing transl)`} />
      &nbsp;
      <FormattedMessage id="errors.probably_invalid" defaultMessage="doesn't look right (missing transl)" />
    </div>;
  }
}

export default injectIntl(BraintreeCardFields, { withRef: true });
