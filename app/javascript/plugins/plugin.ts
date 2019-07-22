import * as EventEmitter from 'eventemitter3';

export interface IPluginConfig {
  id: number;
  active: boolean;
  page_id: number;
  ref: string;
  created_at?: string;
  updated_at?: string;
}

export interface IPluginOptions<T> {
  el: HTMLElement;
  config: T;
  namespace?: string;
  eventEmitter?: any;
  customRenderer?: (instance: any) => any | undefined;
}

// Plugin is the base class from which other
// plugins inherit. It implements an EventEmitter
// with some basic lifecycle methods;
export default class Plugin<T extends IPluginConfig>
  implements IPluginOptions<T> {
  public el: HTMLElement;
  public namespace: string;
  public config: T;
  public events: EventEmitter;
  public customRenderer: (instance: any) => any | undefined;

  constructor(options: IPluginOptions<T>) {
    this.el = options.el;
    this.config = options.config;
    this.namespace = options.namespace || '';
    this.events = options.eventEmitter || new EventEmitter.EventEmitter();
    if (options.customRenderer) {
      this.customRenderer = options.customRenderer;
    }
  }

  public emit(eventName: string, data?: any) {
    this.events.emit(this.privateEventName(eventName), data);
    this.events.emit(`${this.namespace}:${eventName}`, data);
  }

  public on(eventName: string, listener: EventEmitter.ListenerFn, ctx: any) {
    return this.events.on(this.privateEventName(eventName), listener, ctx);
  }

  public listeners(eventName: string) {
    return this.events.listeners(this.privateEventName(eventName));
  }

  public update(options: Partial<IPluginOptions<T>>) {
    if (options.namespace) {
      this.namespace = options.namespace;
    }
    if (options.el) {
      this.el = options.el;
    }
    if (options.config) {
      Object.assign(this.config, options.config);
    }
    this.emit('updated');
  }

  private privateEventName(eventName: string) {
    return `${this.namespace}:${this.config.ref}:${eventName}`;
  }
}
