/* eslint-disable */
// @flow

declare type WebpackModuleHot = {
  accept: (path: string, callback: () => void) => void,
};

declare type WebpackModule = {
  hot: WebpackModuleHot,
};

declare var module: WebpackModule;

declare type FBStandardEvent =
  | 'ViewContent'
  | 'Search'
  | 'AddToCart'
  | 'AddToWishlist'
  | 'InitiateCheckout'
  | 'AddPaymentInfo'
  | 'Purchase'
  | 'Lead'
  | 'CompleteRegistration';

declare type FBEventParams = {
  value?: any,
  currency?: any,
  content_name?: any,
  content_category?: any,
  content_type?: any,
  content_ids?: any[],
  num_items?: any,
};

declare function fbq(
  action: 'init' | 'track' | 'trackCustom',
  eventName: FBStandardEvent,
  data?: FBEventParams
): void;
