// @flow

export var window: typeof window & {
  champaign: ChampaignGlobalObject,
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
  declare export type I18nDict = { [key: string]: I18nDictValue };
  declare export type I18nDictValue = I18nDict | string;
  declare export type I18nFlatDict = { [string]: string };
  declare export type locale= string;
  declare export var translations: { [lang: string]: I18nDict };
  declare export function t(string, options?: { [string]: string }): string;
  declare export default {
    locale: string;
    translations: { [lang: string]: I18nDict };
    t(string, options?: { [string]: string }): string;
  }
}
