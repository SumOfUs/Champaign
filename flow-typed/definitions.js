// @flow

export var window: typeof window & {
  champaign: any,
  optimizelyHook?: void => void,
  fbq?: (...args: any[]) => void,
};



declare type WebpackModule = {
  hot: WebpackModuleHot,
};

declare type WebpackModuleHot = {
  accept: (path: string, callback: () => void) => void,
};

declare var module: WebpackModule;

declare module 'champaign-i18n' {
  declare export type locale= string;
  declare export var translations: Object;
  declare export function t(string, options?: { [string]: string }): string;
  declare export default {
    locale: string;
    translations: Object;
    t(string, options?: { [string]: string }): string;
    lookup(scope: string, options: any): ?string;
  }
}
