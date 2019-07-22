## Plugins

_Note: this documentation is still work in progress and does not cover the full plugin implementation._

There's a `plugins` namespace in the champaign object: `window.champaign.plugins`. The way this is organised follows the following pattern: `window.champaign.plugins.PLUGIN_NAME.PLUGIN_REFERENCE`. Inside that object, there will usually be two properties: `config` and `instance`. More on these later. The TypeScript interfaces for this can be found in [window.d.ts](../../app/javascript/window.d.ts)

```ts
interface IChampaignPluginData<T, M> {
  [ref: string]: {
    config: T;
    instance?: M;
    customRenderer?: (instance: M) => void,
  };
}
```

### Plugin config

Every plugin comes with its configuration data. In fact, every _instance_ of a plugin in page comes with its own configuration data. This is because a template can specify various instances of a plugin. The TypeScript interfaces defined in [window.d.ts](../../app/javascript/window.d.ts) are used in our codebase so they will generally be up to date (builds will fail otherwise).

Each type of plugin will have some configuration data that is specific to that plugin, however, all plugins share some basic plugin configuration parameters. You can find the `IPluginConfig` interface in [plugin.ts](../../app/javascript/plugins/plugin.ts)

```ts
export interface IPluginConfig {
  id: number;
  active: boolean;
  page_id: number;
  ref: string;
  created_at?: string;
  updated_at?: string;
}
```

All other plugins extend from this interface. Check [window.d.ts](../../app/javascript/window.d.ts) to find out what fields each plugin type has.

#### Plugin initialisation

Plugins are automatically initialised on `DOMContentLoaded`, which means that you can edit the plugin configuration object (`window.plugins.[pluginname][ref].config`) before the event is emitted if you want to modify the parameters they're initialised with.

A quick summary of what goes on behind the scenes:
* Rails/Champaign populates the `window.champaign.plugins` object with all the plugins that are configured in the current page.
* There is a `DOMContentLoaded` event handler that goes through that object, attempting to initialise each one of them by looking for three things:
  1. A config object in `window.champaign.plugins.PLUGIN_NAME.PLUGIN_REF.config` with `active: true`.
  2. A corresponding DOM element with an ID matching the pattern: `plugin-{plugin_name}-{plugin_ref}`.
  3. An entry in the [SUPPORTED_PLUGINS](../../app/javascript/plugins/index.ts) list.
* When the previous conditions are met, the plugin initialiser is then called with a few arguments:
  - the `config` for that plugin
  - a reference to the DOM element it will be mounted on
  - a reference to the redux store
  - a reference to the global event emitter
* The plugin initialiser returns a reference to the _instance_ that was just initialised, and this instance is saved in `window.champaign.plugins.PLUGIN_NAME.PLUGIN_REF.instance`.

### Custom renderers
You can implement your own renderer and bypass the default implementation. To do so, you have two options:
1. Specify a `customRenderer` property in the `window.champaign.plugins.PLUGIN_NAME.PLUGIN_REF` object.
2. Set the custom renderer on the interface, by setting `instance.renderer = yourCustomRenderer`

A `customRenderer` must be a function that accepts at least one argument: the plugin instance.

Here's an example "Hello world" custom renderer:

```ts
function customRenderer(instance: Petition) {
  const content = '<span id="hello-world-example">Hello world</span>'
  $(instance.el).html(content);
  $("#hello-world-example").on('click', () => console.log('click detected'));
}

window.champaign.plugins.petition.default.customRenderer = customRenderer;
// or, alternatively, after the DOM has loaded
// window.champaign.plugins.petition.default.instance.renderer = customRenderer;
```

### Public properties and methods

* `config`: A reference to the plugin's configuration. This is only read on initialisation.
* `emit`: See [Events](#Events)
* `on`: See [Events](#Events)
* `events`: See [Events](#Events)
* `listeners`: See [Events](#Events)
* `update(data: Partial<IPluginOptions<T>>)`: Allows you to update the plugin options (namespace, config, dom element, etc). This does not trigger a re-render, so you will have to do that manually. The `data` argument can contain one or more options to be updated.
* `renderer` (Getter / Setter): Allows you to set get or set the [custom renderer](#Custom\ renderers).

#### Events
All plugins have two handy methods for local events: `emit` and `on`:
* `emit(eventName: string, data: any)`: This will emit two identical events, one prefixed with the plugin's namespace and reference, and another prefixed with only the namespace. For instance, for a `petition` plugin with a `default` reference, the calling `window.plugins.petition.default.instance.emit('analytics-event', { ... })` will emit two events: `petition:default:analytics-event`, and `petition:analytics-event`.
* `on(eventName: string, data: any)`: This will set up an event listener *only* on the instance prefixed event. For instance, ``window.plugins.petition.default.instance.on('analytics-event', function (data) { ... })` will listen to `petition:default:analytics-event` but not listen to `petition:analytics-event`. For the second event, you can use the global event emitter explained below.
* `listeners`: Lists the event listeners.

##### Global event emitter
A reference to the global event emitter is held in the `events` property. `instance.events.emit('eventName')` will emit the event as-is on `window.ee` (by default) without prefixing the event. The global event emitter is an instance of [eventemitter3](https://github.com/primus/eventemitter3). See that for more documentation.
