_Note: this documentation is still work in progress._

## Petition plugin

The petition plugin consists of two main parts:
1. A form which can be validated and/or submitted. This form is configured in the backend's page edit view. The form fields and all the necessary data to build the form is then made available via the petition plugin config object (in `window.plugins.petition[ref].config`).
2. The validation and submit functionality. Under the hood, this uses the `api` module to validate or submit, but the petition plugin provides some methods for you to do this seamlessly.

### Instance properties
In addition to the [Plugin](./Plugin.md) properties and methods, `Petition` has a few other public methods and properties:

* `form` (Getter): Returns a reference to the form's DOM element.
*  `formValues` (Getter): Returns a JavaScript object with the form values. The data is stored in a redux store, but this method lets read it as a simple JavaScript object. You can use this data to validate or submit the form programatically.
* `updateForm(data)`: Updates the form data in the redux store. You can pass a partial object, or a complete object. If you want to delete a property or value, you must pass the value as `undefined` so that it gets overwritten.
* `resetMember()`: Resets the member (and the form).
* `validate()`: Validates the form and displays the errors (if any). Returns a promise (resolve/reject depending on error state).
* `submit()`: Submits the form and creates the action. If successful, it also triggers the `onComplete` function.
* `submitOrValidate()`: This triggers the default action.
* `onComplete()`: Triggers the `onComplete` behaviour (scroll transition, `petition:complete:before` events, etc).
* `render()`: Renders the component. If a custom renderer is specified, it will call the custom renderer and pass itself as the first argument. The custom renderer can then use any of the public methods and properties.

#### Hooks

The petition component supports hooks. Hooks are, in essence, asynchronous event listeners that return a promise. When all the promises are resolved, the plugin continues to the next step. For example, an event hook that sends analytics to mixpanel before moving to the next step:

```ts
function beforeCompleteHook(data) {
  const payload = { pageId: data.petition.config.page_id };
  return new Promise((resolve, reject) => {
    mixpanel.track('Petition signed', payload, () => resolve());
  });
}

petition.on('complete:before', beforeCompleteHook);
```

Supported hooks:
* `petition:complete:before` (or `petition:REF:complete:before`): Runs before the "onComplete" transition (which could be a redirect).
