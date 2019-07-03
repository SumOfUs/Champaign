import { Component } from 'react';
import paypal from 'braintree-web/paypal';

export default class PayPal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      paypalInstance: null,
      disabled: true,
    };
  }

  componentDidMount() {
    this.createPayPalInstance(this.props.client);
  }

  componentWillReceiveProps(newProps) {
    if (newProps.client !== this.props.client) {
      this.createPayPalInstance(newProps.client);
    }
  }

  createPayPalInstance(client) {
    paypal.create({ client }, this.onPayPalCreate.bind(this));
  }

  onPayPalCreate(error, paypalInstance) {
    if (error) return;

    this.setState({ paypalInstance, disabled: false }, () => {
      if (this.props.onInit) {
        this.props.onInit();
      }
    });
  }

  flow() {
    if (this.props.vault) return 'vault';
    return 'checkout';
  }

  tokenizeOptions() {
    const { amount, currency, vault } = this.props;
    if (vault) {
      return { flow: 'vault' };
    }
    return { flow: 'checkout', amount, currency };
  }

  submit() {
    const paypalInstance = this.state.paypalInstance;
    return new Promise((resolve, reject) => {
      if (!paypalInstance) return reject();

      paypalInstance.tokenize(this.tokenizeOptions(), (error, payload) => {
        if (error) return reject(error);
        resolve(payload);
      });
    });
  }

  render() {
    return null;
  }
}
