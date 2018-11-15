// flow-typed signature: c93dd3dd98b98a974a7d519a681da7ab
// flow-typed version: <<STUB>>/braintree-web_v^3.5.0

/**
 * Enum for {@link BraintreeError} types.
 * @name BraintreeErrorTypes
 * @enum
 * @readonly
 * @memberof BraintreeError
 * @property {string} CUSTOMER An error caused by the customer.
 * @property {string} MERCHANT An error that is actionable by the merchant.
 * @property {string} NETWORK An error due to a network problem.
 * @property {string} INTERNAL An error caused by Braintree code.
 * @property {string} UNKNOWN An error where the origin is unknown.
 */
declare type BraintreeErrorTypes = "CUSTOMER" | "MERCHANT" | "NETWORK" | "INTERNAL" | "UNKNOWN";

declare interface BraintreeError {
  /**
   * @type {string}
   * @description A code that corresponds to specific errors.
   */
  code: string;

  /**
   * @type {string}
   * @description A short description of the error.
   */
  message: string;

  /**
   * @type {BraintreeError.types}
   * @description The type of error.
   */
  type: BraintreeErrorTypes;

  /**
   * @type {object=}
   * @description Additional information about the error, such as an underlying network error response.
   */
  details: any;
}

declare type BraintreeCallback<T> = (error: BraintreeError, data: T) => void;

type ClientAnalyticsMetadata = {
  sessionId: string;
  sdkVersion: string;
  merchantAppId: string;
}

type Configuration = {
  client: Client;
  gatewayConfiguration: any;
  analyticsMetadata: ClientAnalyticsMetadata;
}

interface CreditCardInfo {
  number: string;
  cvv: string;
  expirationDate: string;
  billingAddress: {
    postalCode?: string;
  }
}

type ClientRequestOptions = { method: string, endpoint: string, data: any, timeout?: number }

declare interface Client {
  getConfiguration(): Configuration;
  getVersion(): ?string;
  request(options: ClientRequestOptions, callback: BraintreeCallback<Object>): void;
  teardown(callback?: () => void): void;
}

declare module 'braintree-web' {
  declare type Client = Client;
  declare module.exports: {
    americanExpress: any, // TODO
    applePay: any, // TODO
    client: $Exports<"braintree-web/client">,
    dataCollector: $Exports<"braintree-web/data-collector">,
    googlePayment: $Exports<"braintree-web/google-payment">,
    hostedFields: $Exports<"braintree-web/hosted-fields">,
    masterpass: any, // TODO
    paymentRequest: any, // TODO
    paypal: $Exports<"braintree-web/paypal">,
    paypalCheckout: any, // TODO
    threeDSecure: any, // TODO
    unionPay: any, // TODO
    usBankAccount: any, // TODO
    vaultManager: any, // TODO
    venmo: any, // TODO
    VERSION: string,
    visaCheckout: any, // TODO
  }
}

declare module 'braintree-web/client' {
  declare type Client = Client;

  declare module.exports: {
    /**
     * @function
     * @description This function is the entry point for the <code>braintree.client</code> module. It is used for creating {@link Client} instances that service communication to Braintree servers.
     * @param {object} options Object containing all {@link Client} options:
     * @param {string} options.authorization A tokenizationKey or clientToken.
     * @param {callback} callback The second argument, <code>data</code>, is the {@link Client} instance.
     * @returns {void}
     * @example
     * var createClient = require('braintree-web/client').create;
     *
     * createClient({
     *   authorization: CLIENT_AUTHORIZATION
     * }, function (createErr, clientInstance) {
     *   ...
     * });
     * @static
     */
    create: (options: { authorization: string }, callback: BraintreeCallback<Client>) => void;
  };
}

declare module 'braintree-web/paypal' {
  declare interface PayPalTokenizeReturn {
    close(): void;
    focus(): void;
  }

  declare interface PayPalShippingAddress {
    recipientName: string;
    line1: string;
    line2: string;
    city: string;
    state: string;
    postalCode: string;
    countryCode: string;
  }

  declare interface PayPalBillingAddress {
    line1: string;
    line2: string;
    city: string;
    state: string;
    postalCode: string;
    countryCode: string;
  }

  declare interface PayPalAccountDetails {
    email: string;
    payerId: string;
    firstName: string;
    lastName: string;
    countryCode: string;
    phone: string;
    shippingAddress: PayPalShippingAddress;
    billingAddress: PayPalBillingAddress;
  }

  declare type PayPalTokenizeOptions = {
    flow: 'vault' | 'checkout',
    intent?: string,
    offerCredit?: boolean,
    useraction?: string,
    amount?: (string | number),
    currency?: string,
    displayName?: string,
    locale?: string,
    enableShippingAddress?: boolean,
    shippingAddressOverride?: PayPalShippingAddress,
    shippingAddressEditable?: boolean,
    billingAgreementDescription?: string,
  }

  declare interface PayPalTokenizePayload {
    nonce: string;
    type: string;
    details: PayPalAccountDetails;
  }

  declare interface PayPal {
    closeWindow(): void;
    focusWindow(): void;
    tokenize(options: PayPalTokenizeOptions, callback: BraintreeCallback<PayPalTokenizePayload>): PayPalTokenizeReturn;
    teardown(callback?: () => void): void;
    VERSION: string;
  }

  declare module.exports: {
    // https://braintree.github.io/braintree-web/current/module-braintree-web_paypal.html#.create
    create(options: { client: Client }, callback: BraintreeCallback<PayPal>): void;
    isSupported(): boolean;
  };
}

declare module 'braintree-web/google-payment' {
  // https://braintree.github.io/braintree-web/current/GooglePayment.html#~tokenizePayload
  declare type TokenizePayload = {
    nonce: string;
    details: {
      cardType: string;
      lastFour: string;
      lastTwo: string;
    };
    description: string;
    type: string;
    binData: {
      commercial: string;
      countryOfIssuance: string;
      debit: string;
      durbinRegulated: string;
      healthcare: string;
      issuingBank: string;
      payroll: string;
      prepaid: string;
      productId: string;
    }
  }

  declare type GooglePaymentMethod = {
    type: string;
    parameters: Object;
    tokenizationSpecification?: {
      type: string;
      parameters: Object;
    }
  }

  declare type GooglePaymentShippingAddressParameters = {
    allowedCountryCodes: string[],
    phoneNumberRequired: boolean,
  }

  declare type GooglePaymentDataRequest = {
    apiVersion?: number;
    apiVersionMinor: number;
    merchantInfo: {
      merchantId: string;
      merchantName?: string;
    };
    allowedPaymentMethods: GooglePaymentMethod[];
    transactionInfo?: GoogleTransactionInfo;
    emailRequired?: boolean;
    shippingAddressRequired?: boolean;
    shippingAddressParameters?: GooglePaymentShippingAddressParameters;
  }

  declare type GoogleTransactionInfo = {
    currencyCode: string;
    totalPriceStatus: "NOT_CURRENTLY_KNOWN" | "ESTIMATED" | "FINAL";
    totalPrice?: string;
    checkoutOption?: "DEFAULT" | "COMPLETE_IMMEDIATE_PURCHASE";
  }

  declare interface GooglePayment {
    createPaymentDataRequest(overrides?: GooglePaymentDataRequest, merchantId?: string, transactionInfo?: GoogleTransactionInfo): Object;
    parseResponse(response: Object, callback: BraintreeCallback<TokenizePayload>): void;
    parseResponse(response: Object): Promise<TokenizePayload>;
    teardown(callback?: BraintreeCallback<any>): void;
  }

  declare module.exports: {
    // https://braintree.github.io/braintree-web/current/module-braintree-web_google-payment.html#.create
    create: (options: { client: Client }, callback: BraintreeCallback<GooglePayment>) => void,
  }
}

declare module 'braintree-web/hosted-fields' {
  declare interface HostedFieldsField {
    selector: string;
    placeholder?: string;
    type?: string;
    formatInput?: boolean;
    select?: boolean | { options: string[] };
  }

  declare interface HostedFieldFieldOptions {
    number: HostedFieldsField;
    expirationDate?: HostedFieldsField;
    expirationMonth?: HostedFieldsField;
    expirationYear?: HostedFieldsField;
    cvv: HostedFieldsField;
    postalCode?: HostedFieldsField;
  }

  declare interface HostedFieldsCardCode {
    name: string;
    size: number;
  }

  declare interface HostedFieldsHostedFieldsCard {
    type: string;
    niceType: string;
    code: HostedFieldsCardCode;
  }

  declare interface HostedFieldsHostedFieldsFieldData {
    container: HTMLElement;
    isFocused: boolean;
    isEmpty: boolean;
    isPotentiallyValid: boolean;
    isValid: boolean;
  }

  declare interface HostedFieldsFieldDataFields {
    number: HostedFieldsHostedFieldsFieldData;
    cvv: HostedFieldsHostedFieldsFieldData;
    expirationDate: HostedFieldsHostedFieldsFieldData;
    expirationMonth: HostedFieldsHostedFieldsFieldData;
    expirationYear: HostedFieldsHostedFieldsFieldData;
    postalCode: HostedFieldsHostedFieldsFieldData;
  }

  declare interface HostedFieldsStateObject {
    cards: HostedFieldsHostedFieldsCard[];
    emittedBy: string;
    fields: HostedFieldsFieldDataFields;
  }

  declare interface HostedFieldsAccountDetails {
    cardType: string;
    lastTwo: string;
    lastFour: string;
  }

  declare interface HostedFieldsTokenizePayload {
    nonce: string;
    details: HostedFieldsAccountDetails;
    type: string;
    description: string;
  }

  declare interface HostedFields {
    addClass(field: string, classname: string, callback?: BraintreeCallback<void>): void;
    clear(field: string, callback?: BraintreeCallback<void>): void;
    focus(field: string, callback?: BraintreeCallback<void>): void;
    getState(): any;
    on(event: string, handler: ((event: any) => any)): void;
    removeAttribute(options: {field: string, attribute: string}, callback?: BraintreeCallback<void>): void;
    removeClass(field: string, classname: string, callback?: BraintreeCallback<void>): void;
    setAttribute(options: {field: string, attribute: string, value: string}, callback?: BraintreeCallback<void>): void;
    setMessage(options: {field: string, message: string}): void;
    setPlaceholder(field: string, placeholder: string, callback?: BraintreeCallback<void>): void;
    styleOptions: any;
    teardown(callback?: BraintreeCallback<any>): void;
    tokenize(options?: { vault: boolean }, callback?: BraintreeCallback<HostedFieldsTokenizePayload>): void;
    VERSION: string;
  }
  declare module.exports: {
    create(options: { client: Client, fields: HostedFieldFieldOptions, styles: any }, callback: BraintreeCallback<HostedFields>): void;
    supportsInputFormatting(): boolean;
  }
}

declare module 'braintree-web/data-collector' {
  declare interface DataCollector {
    VERSION: string;
    deviceData: string;
    teardown(callback?: () => void): void;
  }

  declare module.exports: {
    create(options: { client: Client, kount: boolean, paypal: boolean }, callback: BraintreeCallback<DataCollector>): void
  };
}
