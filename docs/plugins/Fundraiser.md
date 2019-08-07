_Note: this documentation is still work in progress._

## Fundraiser plugin

The fundraiser plugin is one of the more complex plugins we have. This public instance API is still a work in progress.

### Instance properties
In addition to the [Plugin](./Plugin.md) properties and methods, `Fundraiser` has a few other public methods and properties:

* `amount` (Getter / Setter): Get/Set the amount. See `setAmount`.
* `currency` (Getter / Setter): Get/set the currency. See `setCurrency`.
* `recurring` (Getter / Setter): Get/set the "recurring" value. See `setRecurring`
* `storeInVault` (Getter / Setter): Get/set the "storeInVault" value. See `setStoreInVault`.
*  `formValues` (Getter): Returns a JavaScript object with the form values. The data is stored in a redux store, but this method lets read it as a simple JavaScript object. You can use this data to validate or submit the form programatically.
* `addPaymentMethod(paymentMethodData)`: Allows us to create a new payment method. The `paymentMethodData` object will need to contain a `label`, a `setup` function (optional), and the `onSubmit`, `onSuccess`, and `onFailure` callbacks as properties. **Not implemented**.
* `setAmount(amount: number)`: Sets the selected amount.
* `setCurrency(currencyCode: string)`: Sets the selected currency. Sets the default currency if an unsupported currency is given.

* `configureHostedFields(config: HostedFieldsConfiguration): Promise`

  Configures the hosted fields. The `config` parameter is an object with two optional properties: [`styles`](https://braintree.github.io/braintree-web/3.50.0/module-braintree-web_hosted-fields.html#~styleOptions), and [`fields`](https://braintree.github.io/braintree-web/3.50.0/module-braintree-web_hosted-fields.html#~fieldOptions). It returns a Promise that resolves with a hosted fields instance object ([documentation](https://braintree.github.io/braintree-web/3.50.0/HostedFields.html)), or rejects with a braintree error object ([documentation](https://braintree.github.io/braintree-web/3.50.0/BraintreeError.html)).

  **Example**:
  You need to create DOM elements for each of the fields that you pass in the `config` object, and give them a unique ID. For instance, here I'm creating a hosted fields instance with the Card Number, CVV, and Expiry Date fields. For that, I'll need the markup:

  ```html
    <div class="hosted-fields-container">
      <div id="card-number"></div>
      <div id="cvv-number"></div>
      <div id="expiration-date"></div>
    </div>
  ```
  And now I can pass those IDs in my configuration object, along with some basic styles:

  ```js
  fundraiser.configureHostedFields({
    fields: {
      number: {
        selector: '#card-number',
        placeholder: 'Card number',
      },
      cvv: {
        selector: '#cvv-number',
        placeholder: 'CVV',
      },
      expirationDate: {
        selector: '#expiration-date',
        placeholder: 'MM / YY',
      },
    },
    styles: {
      input: {
        color: '#333',
        'font-size': '16px',
      },
      ':focus': { color: '#333' },
      '.valid': { color: '#333' },
    },
  }).then(
      hostedFieldsInstance => {
        // On success, you'll receive the hosted fields instance
        // You can interact with it and listen to events on
        // it (e.g.credit card type detected, etc.)
        // Documentation: https://braintree.github.io/braintree-web/3.50.0/HostedFields.html
      },
      error => {
        // On error, you'll receive a BraintreeError object
        // with the error message and information.
      }
    );
  ```

* `setPaymentType(paymentType: string)`: Sets the payment type (gocardless, paypal, card, etc). If the given payment type is not supported, it will be set to the default payment type.
* `setRecurring(value: boolean)`: Updates the recurring value.
* `setStoreInVault(value: boolean)`: Updates `storeInVault` value, which indicates whether we want to save the payment token/grant. This only affects braintree transactions.
* `form` (Getter): Returns a reference to the form's DOM element.
* `makePayment(): Promise`: Tries to make a donation. This function returns a `Promise` that resolves on success, and rejects on error.
    ```js
    const fundraiser = window.champaign.plugins.fundraiser.default.instance;
    fundraiser
      .setAmount(1)
      .setPaymentType('paypal')
      .makePayment()
      .then(
        (response) => console.log('Success', response),
        (error) => console.log('Failure', error)
      );
    ```
* `onComplete()`: Triggers the `onComplete` behaviour (scroll transition, `fundraiser:complete:before` events, etc).
* `render()`: Renders the component. If a custom renderer is specified, it will call the custom renderer and pass itself as the first argument. The custom renderer can then use any of the public methods and properties.
* `resetMember()`: Resets the member (and the form).
* `state` (Getter): Returns the current state object (readonly).
* `updateForm(data)`: Updates the form data in the redux store. You can pass a partial object, or a complete object. If you want to delete a property or value, you must pass the value as `undefined` so that it gets overwritten.
* `validateForm()`: Validates the form and displays the errors (if any). Returns a promise (resolve/reject depending on error state).

#### Hooks
The fundraiser component supports the following hooks:
* `fundraiser:complete:before` (or `fundraiser:REF:complete:before`): Runs before the "onComplete" transition (which could be a redirect).
