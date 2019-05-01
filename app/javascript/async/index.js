// @flow

type PluginErrorOptions = {
  name?: string,
  message: string,
};

export class PluginError {
  name: string;
  message: string;
  constructor(options: PluginErrorOptions) {
    this.name = options.name || 'PluginError';
    this.message = options.message;
  }

  toString() {
    return `${this.name}: ${this.message}`;
  }
}

export const MODULES = {
  'email-ukparliament': () => import('./email-ukparliament'),
};

// Lists supported async modules
export const list = (): string[] => Object.keys(MODULES);

// Loads an async module.
export const load = async (name: string, options: any) => {
  const loader = MODULES[name];
  if (!loader) {
    throw new PluginError({
      message: `Plugin "${name}" is not available or does not support dynamic loading.`,
    });
  }
  const plugin = await loader();
  plugin.init(options);
};

export const modules = {
  // Attaches the async feature to the champaign global
  // object.
  setup(champaign: any) {
    Object.assign(champaign, {
      modules: {
        load,
        list,
      },
    });
  },
};

export default modules;
