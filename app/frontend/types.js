/* eslint-disable */
// @flow

declare type WebpackModuleHot = {
  accept: (path: string, callback: () => void) => void;
}

declare type WebpackModule = {
  hot: WebpackModuleHot;
};

declare var module: WebpackModule;
