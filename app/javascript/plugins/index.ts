import * as EventEmitter from 'eventemitter3';
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
