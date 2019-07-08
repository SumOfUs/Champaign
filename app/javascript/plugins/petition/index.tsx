import * as EventEmitter from 'eventemitter3';
import * as React from 'react';
import { render } from 'react-dom';
import { Store } from 'redux';
import ComponentWrapper from '../../components/ComponentWrapper';
import { resetMember } from '../../state/member/reducer';
import { IAppState } from '../../types';
import Plugin from '../plugin';
import { PetitionComponent } from './PetitionComponent';

import './petition.css';

export const init = (options: any) => {
  if (!options.el) {
    throw new Error('Petition plugin DOM element not found');
  }

  return new Petition({
    el: options.el,
    namespace: 'petition',
    config: options.config,
    store: options.store,
    eventEmitter: options.eventEmitter,
  });
};

interface IPetitionOptions {
  el: HTMLElement;
  namespace: string;
  config: any; // todo
  store: Store<IAppState>;
  eventEmitter?: EventEmitter;
}

export class Petition extends Plugin {
  public store: Store<IAppState>;

  constructor(options: IPetitionOptions) {
    super(options);
    this.store = options.store;
    this.render();
  }

  public updateForm(fieldName: string, value: string) {
    // tslint:disable-next-line: no-console
    console.info('Petition#updateForm not implemented');
    this.render();
  }

  public resetMember = () => {
    this.store.dispatch(resetMember());
    this.emit('resetMember');
  };

  public submit = () => {
    // tslint:disable-next-line: no-console
    console.info('Petition#submit not implemented');
  };

  public onComplete = () => {
    const listeners = [
      ...this.listeners('complete:before'),
      ...this.events.listeners(this.namespace + ':complete:before'),
    ];

    return Promise.all(listeners.map(l => l(this)))
      .then(() => {
        this.events.emit('complete', { petition: this });
      })
      .then(() => this);
  };

  public render() {
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
