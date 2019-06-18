// @flow
import React from 'react';
import { render } from 'react-dom';
import { Plugin } from '../index';
import { PetitionComponent } from './PetitionComponent';

type PetitionOptions = {
  el: HTMLElement,
  config: any, // todo
};

/*
 */
export class Petition extends Plugin {
  _additionalData: any;
  constructor(options: PetitionOptions) {
    super(options);
    this.render();
  }

  updateForm(fieldName: string, value: string) {
    console.info('Petition#updateForm not implemented');
    this.render();
  }

  submit() {
    console.info('Petition#submit not implemented');
  }

  render() {
    const el = this.el;
    if (el) {
      render(<PetitionComponent date={Date.now()} />, el);
    }
  }
}
export const init = (options: any) => {
  return new Petition({
    el: options.el,
    namespace: 'petition',
    config: options.config,
  });
};
