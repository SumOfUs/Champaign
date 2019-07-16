import * as EventEmitter from 'eventemitter3';
import * as React from 'react';
import { render } from 'react-dom';
import { Store } from 'redux';
import api from '../../api/api';
import ComponentWrapper from '../../components/ComponentWrapper';
import { dispatchFieldUpdate } from '../../state/consent/';
import { resetMember } from '../../state/member/reducer';
import { IAppState } from '../../types';
import { IPetitionPluginConfig } from '../../window';
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
  config: IPetitionPluginConfig;
  store: Store<IAppState>;
  eventEmitter?: EventEmitter;
}

export class Petition extends Plugin<IPetitionPluginConfig> {
  public store: Store<IAppState>;
  private data: {
    values: { [key: string]: any };
    errors: { [key: string]: string[] };
  };

  constructor(options: IPetitionOptions) {
    super(options);
    this.store = options.store;
    this.data = {
      values: {}, // todo: get default values on mount
      errors: {},
    };
    this.render();
  }

  public get form() {
    return this.el.getElementsByClassName('Form')[0];
  }

  public get formValues() {
    return { ...this.data.values, form_id: this.config.form_id };
  }

  public updateForm = (data: { [key: string]: any }) => {
    this.data.values = { ...this.data.values, ...data };
    // this.render();
  };

  public resetMember = () => {
    this.store.dispatch(resetMember());
    this.emit('resetMember');
  };

  public validate = () => {
    return api.pages
      .validateForm(this.config.page_id, this.formValues)
      .then(this.handleErrors);
  };

  public submit = (form: any) => {
    api.pages
      .createAction(this.config.page_id, this.formValues)
      .then(this.handleErrors)
      .then(r => {
        if (!r.errors) {
          this.onComplete();
        }
      });
  };

  public onComplete = () => {
    const listeners = [
      ...this.listeners('complete:before'),
      ...this.events.listeners(this.namespace + ':complete:before'),
    ];

    return Promise.all(listeners.map(l => l(this)))
      .then(() => this.events.emit('complete', { petition: this }))
      .then(() => this);
  };

  public render() {
    const el = this.el;
    if (el) {
      render(
        <ComponentWrapper
          locale={window.I18n.locale}
          store={window.champaign.store}
        >
          <PetitionComponent
            config={this.config}
            values={this.data.values}
            errors={this.data.errors}
            resetMember={this.resetMember}
            onFormChange={this.handleFormChange}
            onValidate={this.validate}
            onSubmit={this.submit}
            eventEmitter={this.events}
            prefillValues={this.updateForm}
          />
        </ComponentWrapper>,
        el
      );
    }
  }

  private handleFormChange = data => {
    Object.keys(data).forEach(key =>
      dispatchFieldUpdate(key, data[key], this.store.dispatch)
    );
    this.data.values = { ...this.data.values, ...data };
  };

  private handleErrors = response => {
    if (response.errors) {
      this.data.errors = response.errors;
    }
    this.render();
    return response;
  };
}
