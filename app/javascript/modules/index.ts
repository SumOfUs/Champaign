/*
 * Usage
 *
 * Import the module (if you need to initialise it manually)
 *    modules.import('ModuleName').then(ModuleName => ...);
 *
 * Load and initialise the module:
 *    modules.load('ModuleName', options).then(instance => ...)
 *
 * List available modules:
 *    modules.list()
 */

const MODULES = {
  StandaloneConsentPrompt: () => import('./consent/StandaloneConsentPrompt'),
  'email-ukparliament': () => import('./EmailParliament'),
  'braintree-web': () => import('./braintree-web'),
  'eoy-thermometer': () => import('./eoy-thermometer'),
  api: () => import('./api'),
};

const modules = {
  async import(moduleName: string) {
    if (!MODULES[moduleName]) {
      throw new Error('Module not found');
    }
    return MODULES[moduleName]();
  },

  async load(moduleName: string, options: any) {
    return modules.import(moduleName).then(module => module.init(options));
  },

  get list() {
    return Object.keys(MODULES);
  },
};

export default modules;
