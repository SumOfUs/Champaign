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
export class Plugin extends EventEmitter {
  el: HTMLElement | void;
  namespace: string;
  config: any;

  constructor(options?: PluginOptions = {}) {
    super();
    this.el = options.el;
    this.config = options.config;
    this.namespace = options.namespace || '';
  }

  update(options: $Shape<PluginOptions>) {
    if (options.namespace) this.namespace = options.namespace;
    if (options.el) this.el = options.el;
    if (options.config) extend(this.config, options.config);
    this.emit(eventName('update', this.namespace));
  }
}

function eventName(eventName: string, namespace: string) {
  return namespace.length ? `${namespace}:${eventName}` : eventName;
}

export const load = async (name: string, ref: string, config?: any) => {
  const loader = SUPPORTED_PLUGINS[name];
  if (!loader) return;

  const el = document.getElementById(`plugin-${name}-${ref}`);
  if (!el) return;

  return (await loader()).init({ el, config: { ...config, ref } });
};
