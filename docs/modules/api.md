_Note: this documentation is still work in progress._

## API module
The api module (work in progress) is basically a Champaign API client.

### Usage
```ts
window.modules.import('api').then(api => {
  // Use api
  api.validateForm(1, {
    form_id: 2,
    email: 'test@example.com',
    name: 'Test'
  }).then(
    success => {
    },
    response => {
      // failure.errors will contain the errors
    }
  ).catch(response => {
    // you can also just catch for the errors
  })
})
```

### API

* `api.pages`:
  - `.validateForm(pageId: number | string, payload: any): Promise`: Validates a form, returns a promise. The promise is resolved on success, rejected on error.
  - `.createAction(pageId: number | string, payload: any): Promise`: Creates an action in a page. The promise is resolved on success, rejected on error.
