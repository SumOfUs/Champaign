## Plugins

_Note: this documentation is still work in progress and does not cover the full plugin implementation._

There's a `plugins` namespace in the champaign object: `window.champaign.plugins`. The way this is organised follows the following pattern: `window.champaign.plugins.PLUGIN_NAME.PLUGIN_REFERENCE`. Inside that object, there will usually be two properties: `config` and `instance`. More on these later. The TypeScript interfaces for this can be found in [window.d.ts](../../app/javascript/window.d.ts)

```ts
interface IChampaignPluginData<T, M> {
  [ref: string]: {
    config: T;
    instance?: M;
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

