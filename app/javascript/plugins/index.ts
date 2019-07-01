import * as EventEmitter from 'eventemitter3';
import { EventEmitterStatic } from 'eventemitter3';
import { extend } from 'lodash';
import { ChampaignGlobalObject } from '../interfaces';

export const SUPPORTED_PLUGINS = {
  actions_thermometer: () => import('./actions_thermometer'),
  call_tool: () => import('./call_tool'),
  donations_thermometer: () => import('./donations_thermometer'),
  email_pension: () => import('./email_pension'),
  email_tool: () => import('./email_tool'),
  fundraiser: () => import('./fundraiser'),
  petition: () => import('./petition'),
};

export const load = async (name: string, ref: string, config?: any) => {
  const loadPluginAsync = SUPPORTED_PLUGINS[name];
  const champaign: ChampaignGlobalObject = window['champaign'];
  const el = document.getElementById(`plugin-${name}-${ref}`);

  if (!loadPluginAsync) return;
  if (!config.active) {
    console.log(`plugin ${name}::${ref} was found but is not active. Pass.`);
    return;
  }

  const plugin = await loadPluginAsync();
  return plugin.init({
    el,
    config: { ...config, ref },
    store: champaign.store,
  });
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
