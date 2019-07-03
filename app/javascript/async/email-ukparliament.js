import React from 'react';
import { render } from 'react-dom';
import { EmailPluginConfig } from './interfaces';
import EmailParliament from '../modules/EmailParliament';

export const init = options => {
  if (!options.config.active) return;
  if (options.el) {
    render(
      <EmailParliament config={options.config} onSend={options.onSend} />,
      options.el
    );
  }
};
