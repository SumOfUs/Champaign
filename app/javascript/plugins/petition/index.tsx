// @flow
import * as React from 'react';
import { render } from 'react-dom';
import { Plugin } from '../index';
import { PetitionComponent } from './PetitionComponent';
import ComponentWrapper from '../../components/ComponentWrapper';
import { resetMember } from '../../state/member/reducer';
import { Store } from 'redux';
import { AppState } from '../../state/types';

import './petition.css';

export const init = (options: any) => {
  if (!options.el) throw new Error('Petition plugin DOM element not found');

  return new Petition({
    el: options.el,
    namespace: 'petition',
    config: options.config,
    store: options.store,
  });
};

type PetitionOptions = {
  el: HTMLElement;
  namespace: string;
  config: any; // todo
  store: Store<AppState>;
};

export class Petition extends Plugin {
  store: Store<AppState>;

  constructor(options: PetitionOptions) {
    super(options);
    this.store = options.store;
    this.render();
  }

  updateForm(fieldName: string, value: string) {
    console.info('Petition#updateForm not implemented');

    this.render();
  }

  resetMember = () => {
    this.store.dispatch(resetMember());
    this.emit('resetMember');
  };

  submit = () => {
    console.info('Petition#submit not implemented');
  };

  render() {
    const el = this.el;
    if (el) {
      render(
        /* Todo: fix the references to window */
        <ComponentWrapper
          locale={(window as any).I18n.locale}
          store={(window as any).champaign.store}
        >
          <PetitionComponent
            config={this.config}
            resetMember={this.resetMember}
            onSubmit={this.submit}
            eventEmitter={this.events}
          />
        </ComponentWrapper>,
        el
      );
    }
  }
}
