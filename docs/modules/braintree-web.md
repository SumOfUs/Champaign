_Note: this documentation is still work in progress._

## `braintree-web` module
This module simply exposes the `braintree-web` npm module. It's a convenient way to create your own payment components, using their methods for creating braintree `client`s, mounting `hostedFields`, etc.

### Usage
```ts
window.modules.import('braintree-web').then(braintree => { ... });
```

For documentation on the braintree npm module, visit: [braintree-web](https://github.com/braintree/braintree-web)
