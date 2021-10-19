import { PAYPAL_FLOW_FAILED } from 'braintree-web/paypal/shared/errors';

export const ProcessIdealPayment = async ({
  localPaymentInstance,
  pageId,
  data,
}) => {
  const { user, amount } = data;
  const { name } = user;

  const opts = {
    paymentType: 'ideal',
    amount: amount.toFixed(2),
    fallback: {
      // see Fallback section for details on these params
      url: 'https://sumofus.org/a/donate',
      buttonText: 'Complete Payment',
    },
    currencyCode: 'EUR',
    givenName: name,
    address: {
      countryCode: 'NL',
    },
    onPaymentStart: function(localData, start) {
      const { paymentId } = localData;
      const payload = {
        paymentId,
        data,
      };

      $.post(
        `/api/payment/braintree/pages/${pageId}/local_payment_transaction`,
        payload
      ).then(resp => {
        console.log('resp', resp);
      });

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
