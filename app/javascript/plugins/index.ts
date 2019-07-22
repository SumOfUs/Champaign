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
  const loader = SUPPORTED_PLUGINS[name];
  const champaign = window.champaign;
  const el = document.getElementById(`plugin-${name}-${ref}`);

  if (loader && config.active) {
    const plugin = await loader();
    return plugin.init({
      el,
      config: { ...config, ref },
      store: champaign.store,
      eventEmitter: window.ee,
    });
  }
};
