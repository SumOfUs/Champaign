import * as EventEmitter from 'eventemitter3';
import { EventEmitterStatic } from 'eventemitter3';
import { extend } from 'lodash';
import { ChampaignGlobalObject } from '../interfaces';

export const SUPPORTED_PLUGINS = {
  petition: () => import('./petition'),
};

interface PluginOptions {
  el: HTMLElement;
  config: any;
  namespace?: string;
  eventEmitter?: EventEmitter<any>;
}

// Plugin is the base class from which other
// plugins inherit. It implements an EventEmitter
// with some basic lifecycle methods;
export class Plugin implements PluginOptions {
  el: HTMLElement;
  namespace: string;
  config: any;
  events: EventEmitter<any>;

  constructor(options: PluginOptions) {
    this.el = options.el;
    this.config = options.config;
    this.namespace = options.namespace || '';
    this.events = options.eventEmitter || new EventEmitter();
  }

  emit(eventName: string, data?: any) {
    const prefix = this.namespace ? `${this.namespace}:` : '';
    this.events.emit(`${prefix}${eventName}`, data);
  }

  update(options: Partial<PluginOptions>) {
    if (options.namespace) this.namespace = options.namespace;
    if (options.el) this.el = options.el;
    if (options.config) extend(this.config, options.config);
    this.emit('updated');
  }
}

export const load = async (name: string, ref: string, config?: any) => {
  if (!SUPPORTED_PLUGINS[name]) return;

  const champaign: ChampaignGlobalObject = window['champaign'];
  const el = document.getElementById(`plugin-${name}-${ref}`);
  if (!el) return;

  return (await SUPPORTED_PLUGINS[name]()).init({
    el,
    config: { ...config, ref },
    store: champaign.store,
  });
};
