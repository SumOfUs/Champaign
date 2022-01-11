import React, { Component } from 'react';
import { injectIntl, FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import braintree from 'braintree-web';
import hostedFields from 'braintree-web/hosted-fields';
import './Braintree.scss';
import ee from '../../shared/pub_sub';

class BraintreeCardFields extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hostedFields: null,
      errors: {
        number: false,
        expirationDate: false,
        cvv: false,
      },
      styles: {
        input: {
          color: '#333',
          'font-size': '16px',
        },
        ':focus': { color: '#333' },
        '.valid': { color: '#333' },
      },
      fields: {
        number: Object.freeze({
          selector: '#braintree-card-number',
          placeholder: this.props.intl.formatMessage({
            id: 'fundraiser.fields.number',
            defaultMessage: 'Card number',
          }),
        }),
        cvv: Object.freeze({
          selector: '#braintree-cvv',
          placeholder: this.props.intl.formatMessage({
            id: 'fundraiser.fields.cvv',
            defaultMessage: 'CVV',
          }),
        }),
        expirationDate: Object.freeze({
          selector: '#braintree-expiration-date',
          placeholder: this.props.intl.formatMessage({
            id: 'fundraiser.fields.expiration_format',
            defaultMessage: 'MM/YY',
          }),
        }),
      },
    };
  }

  bindGlobalEvents() {
    ee.on('fundraiser:configure:hosted_fields', this.configureHostedFields);
  }

  configureHostedFields = (config = {}) => {
    this.setState(
      {
        styles: config.styles || this.state.styles,
        fields: config.fields || this.state.fields,
      },
      () => {
        console.log(this.state.fields);
        if (this.state.hostedFields) {
          return this.teardown();
        }

        if (this.props.client) {
          return this.createHostedFields(this.props.client);
        }
      }
    );
  };

  componentDidMount() {
    if (this.props.client) {
      this.createHostedFields(this.props.client);
    }
    this.bindGlobalEvents();
  }

  componentWillReceiveProps(newProps) {
    if (newProps.client !== this.props.client && newProps.client) {
      this.createHostedFields(newProps.client);
    }
  }

  componentWillUnmount() {
    if (this.state.hostedFields) {
      this.state.hostedFields.teardown();
    }
  }

  createHostedFields(client) {
    const formatMessage = this.props.intl.formatMessage;
    Promise.all([
      braintree.threeDSecure.create(
        {
          client: client,
        },
        (err, threeDSInstance) => {
          if (err) {
            if (window.Sentry) {
              window.Sentry.captureException(err);
            }
            ee.emit('fundraiser:configure:3ds:error', err);
            return;
          }
          ee.emit('fundraiser:configure:3ds:success', threeDSInstance);

          this.setState({ threeDS: threeDSInstance });
        }
      ),
      hostedFields.create(
        {
          client,
          styles: this.state.styles,
          fields: this.state.fields,
        },
        (err, hostedFieldsInstance) => {
          if (err) {
            if (window.Sentry) {
              window.Sentry.captureException(err);
            }
            ee.emit('fundraiser:configure:hosted_fields:error', err);
            return;
          }
          ee.emit(
            'fundraiser:configure:hosted_fields:success',
            hostedFieldsInstance
          );

          this.setState({ hostedFields: hostedFieldsInstance }, () => {
            if (this.props.onInit) {
              this.props.onInit();
            }
          });

          hostedFieldsInstance.on('validityChange', event => {
            const field = event.fields[event.emittedBy];
            const newErrors = {};
            newErrors[event.emittedBy] = !field.isPotentiallyValid;
            this.setState({
              errors: Object.assign({}, this.state.errors, newErrors),
            });
          });

          hostedFieldsInstance.on('cardTypeChange', event => {
            if (event.cards.length === 1) {
              this.setState({ cardType: event.cards[0].type });
            } else {
              this.setState({ cardType: '' });
            }
          });
        }
      ),
    ]);
  }

  teardown() {
    if (!this.state.hostedFields) return null;
    this.state.hostedFields.teardown(() =>
      this.createHostedFields(this.props.client)
    );
  }

  submit(event) {
    if (event) event.preventDefault();
    this.resetErrors();

    return new Promise((resolve, reject) => {
      if (!this.state.hostedFields) return reject();

      this.state.hostedFields.tokenize(
        {
          vault: this.props.recurring,
        },
        (error, data) => {
          if (error) {
            this.processTokenizeErrors(error);
            return reject(error);
          }

          if (this.state.threeDS) {
            this.state.threeDS
              .verifyCard({
                onLookupComplete: function(data, next) {
                  next();
                },
                nonce: payload.nonce,
                bin: payload.details.bin,
              })
              .then(function(payload) {
                if (!payload.liabilityShifted) {
                  console.log('Liability did not shift', payload);
                  return;
                }
              })
              .catch(function(err) {
                console.log(err);
                reject(err);
              });
          }

          this.teardown();
          resolve(data);
        }
      );
    });
  }

  resetErrors() {
    const newErrors = {};
    Object.keys(this.state.errors).forEach(key => {
      newErrors[key] = false;
    });
    this.setState({ errors: newErrors });
  }

  processTokenizeErrors(error) {
    if (error.code === 'HOSTED_FIELDS_FIELDS_INVALID') {
      const errors = Object.assign({}, this.state.errors);
      for (const key of error.details.invalidFieldKeys) {
        errors[key] = true;
      }
      this.setState({ errors: errors });
    }
  }

  currentCardClass(cardType = 'hidden-irrelevant') {
    const icons = {
      'diners-club': 'fa-cc-diners-club',
      jcb: 'fa-cc-jcb',
      'american-express': 'fa-cc-amex',
      discover: 'fa-cc-discover',
      'master-card': 'fa-cc-mastercard',
      visa: 'fa-cc-visa',
      'hidden-irrelevant': 'hidden-irrelevant',
    };

    return icons[cardType];
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
          onSubmit={this.submit}
        >
          <div
            id="braintree-card-number"
            className="BraintreeCardFields__hosted-field BraintreeCardFields__card-number"
          >
            {' '}
          </div>
          <span
            ref="card_type"
            className={
              'BraintreeCardFields__card-type fa ' +
              this.currentCardClass(this.state.cardType)
            }
          />
          {this.state.errors.number && this.renderError('number')}
          <div className="BraintreeCardFields__row clearfix">
            <div
              id="braintree-cvv"
              className="BraintreeCardFields__hosted-field BraintreeCardFields__cvv"
            />
            <div
              id="braintree-expiration-date"
              className="BraintreeCardFields__hosted-field BraintreeCardFields__expiration-date"
            />
          </div>
          {this.state.errors.cvv &&
            this.renderError('cvv', 'BraintreeCardFields__error-msg--col-left')}
          {this.state.errors.expirationDate &&
            this.renderError(
              'expiration',
              'BraintreeCardFields__error-msg--col-right'
            )}
        </form>
        <div className="clearfix"> </div>
      </div>
    );
  }

  renderError(field, className = '') {
    return (
      <div className={`BraintreeCardFields__error-msg error-msg ${className}`}>
        <FormattedMessage
          id={`fundraiser.field_names.${field}`}
          defaultMessage={`${field} (missing transl)`}
        />
        &nbsp;
        <FormattedMessage
          id="errors.probably_invalid"
          defaultMessage="doesn't look right (missing transl)"
        />
      </div>
    );
  }
}

export default injectIntl(BraintreeCardFields, { withRef: true });
