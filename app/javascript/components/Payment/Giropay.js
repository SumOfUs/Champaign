import { PAYPAL_FLOW_FAILED } from 'braintree-web/paypal/shared/errors';

const ProcessGiropay = async ({ localPaymentInstance, data }) => {
  const { user, amount } = data;
  const { name } = user;

  const opts = {
    paymentType: 'giropay',
    amount: amount.toFixed(2),
    fallback: {
      // see Fallback section for details on these params
      url: 'https://sumofus.org/a/donate',
      buttonText: 'Complete Payment',
    },
    currencyCode: 'EUR',
    givenName: name,
    address: {
      countryCode: 'DE',
    },
    onPaymentStart: function(data, start) {
      start();
    },
  };

  try {
    const resp = await localPaymentInstance.startPayment(opts);
    return resp.nonce;
  } catch (e) {
    console.log('LocalPayment ERROR', e);
  }
};

export default ProcessGiropay;
