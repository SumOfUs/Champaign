import * as EventEmitter from 'eventemitter3';

export interface PluginOptions {
  el: HTMLElement;
  config: any;
  namespace?: string;
  eventEmitter?: any;
}

// Plugin is the base class from which other
// plugins inherit. It implements an EventEmitter
// with some basic lifecycle methods;
export default class Plugin implements PluginOptions {
  el: HTMLElement;
  namespace: string;
  config: any;
  events: EventEmitter;

  constructor(options: PluginOptions) {
    this.el = options.el;
    this.config = options.config;
    this.namespace = options.namespace || '';
    this.events = options.eventEmitter || new EventEmitter.EventEmitter();
  }

  emit(eventName: string, data?: any) {
    const prefix = this.namespace ? `${this.namespace}:` : '';
    this.events.emit(`${prefix}${eventName}`, data);
  }

  update(options: Partial<PluginOptions>) {
    if (options.namespace) this.namespace = options.namespace;
    if (options.el) this.el = options.el;
    if (options.config) Object.assign(this.config, options.config);
    this.emit('updated');
  }
}
