import * as EventEmitter from 'eventemitter3';

export interface IPluginConfig {
  id: number;
  active: boolean;
  page_id: number;
  created_at: string;
  updated_at: string;
  ref: string;
}

export interface IPluginOptions {
  el: HTMLElement;
  config: any;
  namespace?: string;
  eventEmitter?: any;
}

// Plugin is the base class from which other
// plugins inherit. It implements an EventEmitter
// with some basic lifecycle methods;
export default class Plugin implements IPluginOptions {
  public el: HTMLElement;
  public namespace: string;
  public config: any;
  public events: EventEmitter;

  constructor(options: IPluginOptions) {
    this.el = options.el;
    this.config = options.config;
    this.namespace = options.namespace || '';
    this.events = options.eventEmitter || new EventEmitter.EventEmitter();
  }

  public emit(eventName: string, data?: any) {
    const prefix = this.namespace ? `${this.namespace}:` : '';
    this.events.emit(`${prefix}${eventName}`, data);
  }

  public update(options: Partial<IPluginOptions>) {
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
}
