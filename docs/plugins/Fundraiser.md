_Note: this documentation is still work in progress._

## Fundraiser plugin

The fundraiser plugin is one of the more complex plugins we have. This public instance API is still a work in progress.

### Instance properties
In addition to the [Plugin](./Plugin.md) properties and methods, `Fundraiser` has a few other public methods and properties:

* `addPaymentMethod(paymentMethodData)`: Allows us to create a new payment method. The `paymentMethodData` object will need to contain a `label`, a `setup` function (optional), and the `onSubmit`, `onSuccess`, and `onFailure` callbacks as properties.
* `changeAmount(amount: number)`: Changes the selected amount.
* `changeCurrency(currencyCode: string)`: Changes the selected currency. Throws an `UnknownCurrencyCode` error if the currency is not supported.
* `form` (Getter): Returns a reference to the form's DOM element.
*  `formValues` (Getter): Returns a JavaScript object with the form values. The data is stored in a redux store, but this method lets read it as a simple JavaScript object. You can use this data to validate or submit the form programatically.
* `updateForm(data)`: Updates the form data in the redux store. You can pass a partial object, or a complete object. If you want to delete a property or value, you must pass the value as `undefined` so that it gets overwritten.
* `resetMember()`: Resets the member (and the form).
* `validateForm()`: Validates the form and displays the errors (if any). Returns a promise (resolve/reject depending on error state).
* `submitForm()`: Submits the form and creates the action. If successful, it also triggers the `onComplete` function.
* `submitDonation()`: Tries to make a donation.
* `onComplete()`: Triggers the `onComplete` behaviour (scroll transition, `fundraiser:complete:before` events, etc).
* `render()`: Renders the component. If a custom renderer is specified, it will call the custom renderer and pass itself as the first argument. The custom renderer can then use any of the public methods and properties.

#### Hooks
The fundraiser component supports the following hooks:
* `fundraiser:complete:before` (or `fundraiser:REF:complete:before`): Runs before the "onComplete" transition (which could be a redirect).
