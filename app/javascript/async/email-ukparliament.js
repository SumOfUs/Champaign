// @flow
import React from 'react';
import { render } from 'react-dom';
import { EmailPluginConfig } from './interfaces';
import EmailParliament from '../modules/EmailParliament';

type Options = {
  el: HTMLElement,
  config: EmailPluginConfig,
  [key: string]: any,
};

export const init = (options: Options) => {
  if (!options.config.active) return;
  if (options.el) {
    render(
      <EmailParliament config={options.config} onSend={options.onSend} />,
      options.el
    );
  }
};
