// @flow
import EventEmitter from 'eventemitter3';
import { extend } from 'lodash';

export const SUPPORTED_PLUGINS = {
  petition: () => import('./petition').then(plugin => plugin),
};

interface PluginOptions {
  el?: HTMLElement;
  namespace?: string;
  config?: any;
}

// Plugin is the base class from which other
// plugins inherit. It implements an EventEmitter
// with some basic lifecycle methods;
export class Plugin {
  el: HTMLElement | void;
  namespace: string;
  config: any;
  events: EventEmitter;

  constructor(options?: PluginOptions = {}) {
    this.el = options.el;
    this.config = options.config;
    this.namespace = options.namespace || '';
    this.events = new EventEmitter();
  }

  emit(eventName: string, data: any) {
    const prefix = this.namespace ? `${this.namespace}:` : '';
    this.events.emit(`${prefix}${eventName}`, data);
  }

  update(options: $Shape<PluginOptions>) {
    if (options.namespace) this.namespace = options.namespace;
    if (options.el) this.el = options.el;
    if (options.config) extend(this.config, options.config);
    this.emit('updated');
  }
}

export const load = async (name: string, ref: string, config?: any) => {
  const loader = SUPPORTED_PLUGINS[name];
  if (!loader) return;

  const el = document.getElementById(`plugin-${name}-${ref}`);
  if (!el) return;

  return (await loader()).init({
    el,
    config: { ...config, ref },
    store: window.champaign.store,
  });
};
