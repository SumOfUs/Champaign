_Note: this documentation is still work in progress._

## Modules

Modules provide functionality that can be loaded asynchronously and on-demand.

### Usage

The `window.champaign.modules` provides the some functionality to list, import and load available modules.

* `window.modules.list`: Returns an array of (available) module names. When importing or loading a module, you'll use this name.
* `window.modules.import`: Imports the module and resolves the promise with the module object. This function returns a promise. Example usage:
    ```ts
      window.module.import('braintree-web').then(braintree => { ... });
    ```
* `window.modules.load`: Imports _and loads_ a module. You must specify the module name, and the configuration parameters passed to load the module (if relevant). This function returns a promise. Example usage:
    ```ts
    window.module.load('StandaloneConsentPrompt', {
      el: document.getElementById('some-id')
    }).then(instance => {
      // use instance
    });
    ```

It will make sense to simply import some modules, but load others. The documentation for each module will specify what makes sense in each case.

### Available modules
* [api](./api.md)
* [braintree-web](./braintree-web.md)
* [StandaloneConsentPrompt](../../app/javascript/modules/StandaloneConsentPrompt/index.ts) (Pending documentation)
