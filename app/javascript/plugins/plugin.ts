import * as EventEmitter from 'eventemitter3';
import { unmountComponentAtNode } from 'react-dom';
import { Store } from 'redux';
import { IAppState } from '../types';

export interface IPluginConfig {
  id: number;
  active: boolean;
  page_id: number;
  ref: string;
  created_at?: string;
  updated_at?: string;
}

export interface IPluginOptions<T> {
  config: T;
  customRenderer?: (instance: any) => any | undefined;
  el: HTMLElement;
  eventEmitter?: any;
  namespace?: string;
  store?: Store<IAppState>;
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
  public store?: Store<IAppState>;

  constructor(options: IPluginOptions<T>) {
    this.config = options.config;
    this.el = options.el;
    this.events = options.eventEmitter || new EventEmitter.EventEmitter();
    this.namespace = options.namespace || '';
    this.store = options.store;
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

  get renderer() {
    return this.customRenderer;
  }

  set renderer(customRenderer: (instance: any) => any) {
    this.customRenderer = customRenderer;

    if (this['render']) {
      unmountComponentAtNode(this.el);
      this['render']();
    }
  }

  private privateEventName(eventName: string) {
    return `${this.namespace}:${this.config.ref}:${eventName}`;
  }
}
