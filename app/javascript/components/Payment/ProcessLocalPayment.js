export const ProcessLocalPayment = async ({
  localPaymentInstance,
  pageId,
  data,
  paymentType,
}) => {
  const { user, amount } = data;
  const { name } = user;

  function getCountryCode() {
    switch (paymentType) {
      case 'ideal':
        return 'NL';
      case 'giropay':
        return 'DE';
    }
  }

  function getCurrencyCode() {
    switch (paymentType) {
      case 'ideal':
      case 'giropay':
        return 'EUR';
    }
  }

  const opts = {
    paymentType,
    amount: amount.toFixed(2),
    fallback: {
      // see Fallback section for details on these params
      url: 'https://sumofus.org/a/donate',
      buttonText: 'Complete Payment',
    },
    currencyCode: getCurrencyCode(),
    givenName: name,
    address: {
      countryCode: getCountryCode(),
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
