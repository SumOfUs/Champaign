import * as EventEmitter from 'eventemitter3';
import { omit } from 'lodash';
import * as React from 'react';
import { render } from 'react-dom';
import { Store } from 'redux';
import api from '../../api';
import ComponentWrapper from '../../components/ComponentWrapper';
import { formValues } from '../../modules/form_values';
import { transitionFromTo } from '../../modules/transition';
import { setSubmitting, updateForm } from '../../state/forms';
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
  private errors: { [key: string]: string[] };

  constructor(options: IPetitionOptions) {
    super(options);
    this.store = options.store;
    this.initState();
    this.render();
  }

  public get form() {
    return this.el.getElementsByClassName('Form')[0];
  }

  public get formValues() {
    const fieldValues = omit(
      this.store.getState().forms[this.config.form_id] || {},
      'submitting'
    );
    return {
      form_id: this.config.form_id,
      ...fieldValues,
    };
  }

  public updateForm(data: { [key: string]: any }) {
    this.store.dispatch(
      updateForm(this.config.form_id, { ...this.formValues, ...data })
    );
  }

  public resetMember = () => {
    this.store.dispatch(resetMember());
    this.initState();
    this.render();
    this.emit('resetMember');
  };

  public validate = () => {
    this.setSubmitting(true);
    return api.pages
      .validateForm(this.config.page_id, this.formValues)
      .then(this.handleErrors.bind(this))
      .then(response => {
        if (!response.errors) {
          this.emit('validated', this);
        }
        throw response;
      });
  };

  public submit = () => {
    this.setSubmitting(true);
    return api.pages
      .createAction(this.config.page_id, this.formValues)
      .then(this.handleErrors.bind(this))
      .then(r => {
        if (!r.errors) {
          this.onComplete();
        }
      });
  };

  public submitOrValidate = () => {
    // Check if this form was a validate-only form.
    // The template can set a data-form-action="validate"
    if (this.el.dataset.action === 'validate') {
      return this.validate()
        .then(() => this.onCompleteTransition())
        .then(() => this);
    }
    return this.submit()
      .then(() => this.onCompleteTransition())
      .then(() => this);
  };

  public onComplete = () => {
    const listeners = [
      ...this.listeners('complete:before'),
      ...this.events.listeners(this.namespace + ':complete:before'),
    ];

    return Promise.all(listeners.map(l => l(this)))
      .then(() => this.events.emit('complete', { petition: this }))
      .then(() => this.onCompleteTransition())
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
            values={this.formValues}
            errors={this.errors}
            resetMember={this.resetMember}
            onValidate={this.validate}
            onSubmit={this.submitOrValidate}
            eventEmitter={this.events}
          />
        </ComponentWrapper>,
        el
      );
    }
  }

  private setSubmitting(submitting: boolean) {
    this.store.dispatch(setSubmitting(this.config.form_id, submitting));
  }

  private handleErrors(response) {
    if (response.errors) {
      this.errors = response.errors;
    }
    this.setSubmitting(false);
    this.render();
    return response;
  }

  private initState() {
    this.store.dispatch(
      updateForm(this.config.form_id, formValues(this.config.fields))
    );
    this.errors = {};
  }

  private onCompleteTransition() {
    if (!this.el.dataset.transition) {
      return;
    }
    transitionFromTo(this.el.dataset.transition);
  }
}
